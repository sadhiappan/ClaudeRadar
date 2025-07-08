import Foundation
import SwiftUI
import Combine
import UserNotifications
import AppKit

class UsageDataManager: ObservableObject {
    static let shared = UsageDataManager()
    
    @Published var currentSession: ClaudeSession?
    @Published var recentSessions: [ClaudeSession] = []
    @Published var usageStatistics: UsageStatistics = .empty
    @Published var isMonitoring: Bool = false
    @Published var lastUpdateTime: Date = Date()
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var projectUsage: [ProjectUsage] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var monitoringTimer: Timer?
    private let dataLoader: DataLoading
    private let sessionCalculator = SessionCalculator()
    
    // User preferences
    @AppStorage("tokenPlan") private var tokenPlan: TokenPlan = .pro
    @AppStorage("refreshInterval") private var refreshInterval: Double = 3.0
    @AppStorage("claudeDataPath") private var claudeDataPath: String = ""
    
    private init() {
        self.dataLoader = ClaudeDataLoader()
        setupPreferencesObserver()
        setupAppLifecycleObservers()
    }
    
    // Dependency injection constructor (for testing)
    init(dataLoader: DataLoading) {
        self.dataLoader = dataLoader
        setupPreferencesObserver()
        setupAppLifecycleObservers()
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        guard !isMonitoring else { 
            print("⚠️ Already monitoring")
            return 
        }
        
        print("🚀 Starting monitoring...")
        isMonitoring = true
        
        // Immediate refresh
        refreshData()
        
        // Setup timer for periodic updates
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            print("⏰ Timer tick - refreshing data")
            self?.refreshData()
        }
        
        print("✅ Monitoring started with \(refreshInterval)s interval")
    }
    
    func stopMonitoring() {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
    }
    
    func refreshData() {
        print("🔄 RefreshData called")
        Task {
            await MainActor.run {
                isLoading = true
            }
            await loadUsageData()
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func exportData() {
        print("📤 Export data button clicked")
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "claude-usage-\(Self.dateFormatter.string(from: Date())).json"
        panel.title = "Export Claude Usage Data"
        panel.prompt = "Export"
        
        print("📂 Opening save panel...")
        let result = panel.runModal()
        print("📂 Save panel result: \(result == .OK ? "OK" : "Cancel")")
        
        if result == .OK {
            print("💾 Exporting to: \(panel.url?.path ?? "unknown")")
            exportUsageData(to: panel.url)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupPreferencesObserver() {
        // Observe preference changes
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.handlePreferencesChange()
            }
            .store(in: &cancellables)
    }
    
    private func handlePreferencesChange() {
        // Restart monitoring with new interval if needed
        if isMonitoring {
            stopMonitoring()
            startMonitoring()
        }
    }
    
    @MainActor
    private func loadUsageData() async {
        print("🔄 Starting data load...")
        do {
            // TDD FIX: Ensure we use auto-discovery for Claude paths, ignore bad stored values
            let claudePath: String? = nil  // Always auto-discover for now
            print("📂 Loading from path: \(claudePath ?? "auto-discover")")
            
            let entries = try await dataLoader.loadUsageEntries(from: claudePath)
            print("📊 Loaded \(entries.count) usage entries")
            
            // Process entries into sessions
            let sessions = sessionCalculator.calculateSessions(from: entries, plan: tokenPlan)
            print("🎯 Calculated \(sessions.count) sessions")
            
            // Calculate multi-session aggregated burn rate (Python parity)
            let now = Date()
            let aggregatedBurnRate = sessionCalculator.calculateHourlyAggregatedBurnRate(
                from: sessions, 
                currentTime: now
            )
            
            if let rate = aggregatedBurnRate {
                print("🔥 Multi-session burn rate: \(String(format: "%.1f", rate)) tokens/min")
            }
            
            var updatedSessions = sessions
            
            // Update current session with improved burn rate
            if let activeSessionIndex = sessions.firstIndex(where: { $0.isActive }) {
                var activeSession = sessions[activeSessionIndex]
                
                // Use aggregated burn rate if available, otherwise keep individual session rate
                if let aggregatedRate = aggregatedBurnRate {
                    activeSession.burnRate = aggregatedRate
                    updatedSessions[activeSessionIndex] = activeSession
                    print("✅ Updated active session with multi-session burn rate: \(String(format: "%.1f", aggregatedRate)) tokens/min")
                } else {
                    print("✅ Found active session: \(activeSession.tokenCount) tokens (individual rate)")
                }
            } else {
                print("⚠️ No active session found")
            }
            
            // Calculate project usage from entries
            self.projectUsage = calculateProjectUsage(from: entries)
            
            // Update published properties
            self.recentSessions = updatedSessions
            self.currentSession = updatedSessions.first { $0.isActive }
            self.usageStatistics = calculateStatistics(from: sessions)
            self.lastUpdateTime = Date()
            self.errorMessage = nil
            
            print("✅ Data load completed successfully")
            
            // Update menu bar icon if needed
            updateMenuBarIcon()
            
            // Check for notifications
            checkForNotifications()
            
        } catch {
            print("❌ Error loading usage data: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func calculateProjectUsage(from entries: [UsageEntry]) -> [ProjectUsage] {
        guard !entries.isEmpty else { 
            print("📊 No entries provided for project usage calculation")
            return [] 
        }
        
        print("📊 Calculating project usage from \(entries.count) entries")
        
        // Group entries by project path
        var projectData: [String: [UsageEntry]] = [:]
        
        for entry in entries {
            let projectPath = extractProjectPath(from: entry)
            projectData[projectPath, default: []].append(entry)
        }
        
        print("📊 Found \(projectData.count) unique projects")
        
        let totalTokens = entries.reduce(0) { $0 + $1.totalTokens }
        var projects: [ProjectUsage] = []
        
        for (projectPath, projectEntries) in projectData {
            let projectTokens = projectEntries.reduce(0) { $0 + $1.totalTokens }
            let lastUsed = projectEntries.map(\.timestamp).max() ?? Date()
            let sessionCount = calculateSessionCount(for: projectEntries)
            let averageTokens = sessionCount > 0 ? projectTokens / sessionCount : 0
            let percentage = totalTokens > 0 ? (Double(projectTokens) / Double(totalTokens)) * 100 : 0
            
            let projectUsage = ProjectUsage(
                id: projectPath,
                name: extractProjectName(from: projectPath),
                fullPath: projectPath,
                totalTokens: projectTokens,
                sessionCount: sessionCount,
                lastUsed: lastUsed,
                averageTokensPerSession: averageTokens,
                percentage: percentage
            )
            
            print("📊 Project path: '\(projectPath)'")
            print("📊 Project name: '\(projectUsage.name)'") 
            print("📊 Project displayName: '\(projectUsage.displayName)'")
            print("📊 Project stats: \(projectTokens) tokens, last used: \(projectUsage.lastUsedDisplay)")
            projects.append(projectUsage)
        }
        
        // Sort by total tokens (descending) and return top projects
        let sortedProjects = projects.sorted { $0.totalTokens > $1.totalTokens }
        print("📊 Returning \(sortedProjects.count) projects sorted by usage")
        return sortedProjects
    }
    
    private func extractProjectPath(from entry: UsageEntry) -> String {
        // Use the project path from the entry if available
        return entry.projectPath ?? "/Users/shivadhiappan/Documents/code/Unknown"
    }
    
    private func extractProjectName(from path: String) -> String {
        // If the path doesn't contain slashes, it's already a clean project name
        if !path.contains("/") {
            return path
        }
        
        // For paths, extract the last meaningful component
        return URL(fileURLWithPath: path).lastPathComponent
    }
    
    private func calculateSessionCount(for entries: [UsageEntry]) -> Int {
        // Group entries by day or session boundaries
        // This is a simplified implementation
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }
        return groupedByDay.count
    }
    
    private func calculateStatistics(from sessions: [ClaudeSession]) -> UsageStatistics {
        guard !sessions.isEmpty else { return .empty }
        
        let totalTokens = sessions.reduce(0) { $0 + $1.tokenCount }
        let totalCost = sessions.reduce(0.0) { $0 + $1.cost }
        let averageTokens = totalTokens / sessions.count
        let averageCost = totalCost / Double(sessions.count)
        
        // Find peak usage day (simplified)
        let peakSession = sessions.max { $0.tokenCount < $1.tokenCount }
        
        return UsageStatistics(
            totalSessions: sessions.count,
            totalTokensUsed: totalTokens,
            totalCost: totalCost,
            averageTokensPerSession: averageTokens,
            averageCostPerSession: averageCost,
            peakUsageDay: peakSession?.startTime,
            currentStreak: calculateCurrentStreak(from: sessions)
        )
    }
    
    private func calculateCurrentStreak(from sessions: [ClaudeSession]) -> Int {
        // Simplified streak calculation - consecutive days with sessions
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        
        for i in 0..<30 { // Check last 30 days
            let date = calendar.date(byAdding: .day, value: -i, to: today)!
            let hasSessionOnDate = sessions.contains { session in
                calendar.isDate(session.startTime, inSameDayAs: date)
            }
            
            if hasSessionOnDate {
                streak += 1
            } else if i > 0 {
                break // Streak broken
            }
        }
        
        return streak
    }
    
    private func updateMenuBarIcon() {
        // Update menu bar icon based on current session status
        // This would be implemented in the AppDelegate
        NotificationCenter.default.post(
            name: .updateMenuBarIcon,
            object: currentSession
        )
    }
    
    private func checkForNotifications() {
        guard let session = currentSession else { return }
        
        let threshold = UserDefaults.standard.double(forKey: "notificationThreshold")
        let showNotifications = UserDefaults.standard.bool(forKey: "showNotifications")
        
        guard showNotifications else { return }
        
        if session.progress >= threshold {
            sendNotification(
                title: "Token Usage Warning",
                body: "You've used \(Int(session.progress * 100))% of your tokens",
                type: .tokenWarning
            )
        }
        
        if let timeRemaining = session.timeRemaining, timeRemaining < 300 { // 5 minutes
            sendNotification(
                title: "Session Expiring Soon",
                body: "Your session expires in \(Int(timeRemaining / 60)) minutes",
                type: .sessionExpiry
            )
        }
    }
    
    private func sendNotification(title: String, body: String, type: NotificationType) {
        // TODO: Implement notifications in future update
        print("📱 Notification: \(title) - \(body)")
    }
    
    private func exportUsageData(to url: URL?) {
        guard let url = url else { return }
        
        let exportData = ExportData(
            sessions: recentSessions,
            statistics: usageStatistics,
            exportDate: Date()
        )
        
        do {
            let jsonData = try JSONEncoder().encode(exportData)
            try jsonData.write(to: url)
        } catch {
            print("Failed to export data: \(error)")
        }
    }
    
    private func setupAppLifecycleObservers() {
        // For menu bar apps, we should only pause monitoring during system sleep
        // or when explicitly stopped by user, not when app becomes "inactive"
        
        // Monitor system sleep/wake instead of app active/inactive
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.pauseMonitoringForSleep()
        }
        
        NotificationCenter.default.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.resumeMonitoringFromSleep()
        }
    }
    
    private func pauseMonitoringForSleep() {
        guard isMonitoring else { return }
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        print("💤 Monitoring paused (system sleep)")
    }
    
    private func resumeMonitoringFromSleep() {
        guard isMonitoring, monitoringTimer == nil else { return }
        
        // Setup timer for periodic updates
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            print("⏰ Timer tick - refreshing data")
            self?.refreshData()
        }
        print("☀️ Monitoring resumed (system wake)")
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter
    }()
}

// MARK: - Export Data Structure

struct ExportData: Codable {
    let sessions: [ClaudeSession]
    let statistics: UsageStatistics
    let exportDate: Date
}

// MARK: - Notification Names

extension Notification.Name {
    static let updateMenuBarIcon = Notification.Name("updateMenuBarIcon")
}