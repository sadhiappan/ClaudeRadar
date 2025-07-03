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
    }
    
    // Dependency injection constructor (for testing)
    init(dataLoader: DataLoading) {
        self.dataLoader = dataLoader
        setupPreferencesObserver()
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
        panel.nameFieldStringValue = "claude-usage-\(dateFormatter.string(from: Date())).json"
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter
    }
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