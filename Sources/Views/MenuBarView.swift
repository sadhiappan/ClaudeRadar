import SwiftUI
import Charts

struct MenuBarView: View {
    @EnvironmentObject var usageManager: UsageDataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTimeRange: TimeRange = .today
    
    var body: some View {
        Group {
            if usageManager.isLoading && usageManager.currentSession == nil {
                // Show shimmer loading state for initial load
                LoadingStateView(showFullInterface: true)
                    .frame(width: DesignTokens.Layout.menuBarWidth)
                    .transition(
                        AccessibilitySystem.ReducedMotion.isEnabled 
                            ? .identity 
                            : .opacity.combined(with: .scale(scale: 0.95))
                    )
            } else {
                // Show normal interface
                VStack(spacing: 0) {
                    // Modern Gradient Header
                    CompleteGradientHeader(
                        session: usageManager.currentSession,
                        themeManager: themeManager,
                        onRefresh: {
                            do {
                                print("🔄 Refresh button clicked")
                                usageManager.refreshData()
                            } catch {
                                print("❌ Refresh failed: \(error)")
                            }
                        }
                    )
                    
                    Divider().opacity(0.3)
                    
                    // Current Session Info
                    currentSessionView
                    
                    Divider().opacity(0.5)
                    
                    // Bottom actions row
                    quickActionsView
                }
                .background(themeManager.currentTheme.background)
                .frame(width: DesignTokens.Layout.menuBarWidth)
                .transition(
                    AccessibilitySystem.ReducedMotion.isEnabled 
                        ? .identity 
                        : .opacity.combined(with: .scale(scale: 0.95))
                )
            }
        }
        .onAppear {
            print("📱 MenuBarView appeared - starting monitoring")
            usageManager.startMonitoring()
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "gauge.high")
                .foregroundColor(themeManager.currentTheme.accent)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: .spacingXs) {
                Text("Claude Radar")
                    .font(.semanticAppTitle)
                    .foregroundColor(themeManager.currentTheme.text)
                
                Text("Token Usage Monitor")
                    .font(.appSubtitle)
                    .foregroundColor(themeManager.currentTheme.secondaryText)
            }
            
            Spacer()
            
            Button(action: { 
                print("🔄 Refresh button clicked")
                usageManager.refreshData() 
            }) {
                if usageManager.isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 12, height: 12)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
            }
            .buttonStyle(HoverButtonStyle())
            .accessibilityInteractiveButton(
                label: AccessibilitySystem.Labels.refreshButtonLabel(isLoading: usageManager.isLoading),
                hint: AccessibilitySystem.Hints.refreshButton
            ) {
                usageManager.refreshData()
            }
            .keyboardNavigable {
                usageManager.refreshData()
            }
            .disabled(usageManager.isLoading)
        }
        .padding(.horizontal, .spacingLg)
        .padding(.vertical, .spacingMd)
    }
    
    private var currentSessionView: some View {
        VStack(spacing: .spacingMd) {
            // Header with better proportions
            HStack(alignment: .top, spacing: .spacingMd) {
                VStack(alignment: .leading, spacing: .spacingXs) {
                    Text("Current Session")
                        .font(.semanticSectionTitle)
                        .dynamicTypeScaled(font: .semanticSectionTitle)
                        .highContrastAdjusted(color: themeManager.currentTheme.secondaryText)
                        .accessibilityHeading(.h2)
                    
                    if let session = usageManager.currentSession {
                        let layoutData = session.metricsLayoutData
                        
                        Text("\(session.tokenCount) tokens")
                            .font(.semanticTokenCount)
                            .dynamicTypeScaled(font: .semanticTokenCount)
                            .highContrastAdjusted(color: themeManager.currentTheme.text)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .allowsTightening(true)
                            .truncationMode(.tail)
                            .accessibilityLabel("Current session usage: \(session.tokenCount) tokens")
                        
                        HStack(spacing: .spacingXs) {
                            Circle()
                                .fill(Color(session.statusColor))
                                .frame(width: DesignTokens.Layout.iconSize, height: DesignTokens.Layout.iconSize)
                            Text(layoutData.statusMessage)
                                .font(.semanticSessionStatus)
                                .dynamicTypeScaled(font: .semanticSessionStatus)
                                .highContrastAdjusted(color: Color(session.statusColor))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .allowsTightening(true)
                                .truncationMode(.tail)
                                .accessibilityStatus(status: layoutData.statusMessage, isActive: session.isActive)
                        }
                    } else {
                        Text("No active session")
                            .font(.semanticSessionStatus)
                            .dynamicTypeScaled(font: .semanticSessionStatus)
                            .highContrastAdjusted(color: themeManager.currentTheme.secondaryText)
                            .accessibilityStatus(status: "No active session", isActive: false)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minWidth: 180)
                
                if let session = usageManager.currentSession {
                    VStack(spacing: 2) {
                        CircularProgressView(
                            progress: Double(session.tokenCount) / Double(session.tokenLimit),
                            color: progressColor(for: session.tokenCount, limit: session.tokenLimit)
                        )
                        .frame(width: 35, height: 35)
                        
                        Text("\(Int(session.progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Session progress: \(Int(session.progress * 100)) percent")
                    }
                    .frame(width: 45)
                }
            }
            
            // Improved metrics with flexible layout
            if let session = usageManager.currentSession {
                let layoutData = session.metricsLayoutData
                
                // Current Usage section with centered title
                VStack(alignment: .center, spacing: .spacing1) {
                    Text("Current Usage")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .dynamicTypeScaled(font: .headline)
                        .highContrastAdjusted(color: .textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibilityHeading(.h3)
                    
                    HStack(spacing: .spacingXs) {
                        CompactMetric(
                            icon: "speedometer",
                            color: .accentOrange,
                            label: "Rate",
                            value: layoutData.burnRateDisplay
                        )
                        .frame(maxWidth: .infinity)
                        .layoutPriority(1)
                        
                        CompactMetric(
                            icon: "timer.circle",
                            color: .accentBlue,
                            label: "Resets",
                            value: layoutData.timeRemainingDisplay
                        )
                        .frame(maxWidth: .infinity)
                        .layoutPriority(1)
                    }
                }
                
                // Model Usage Breakdown - Always show all models
                VStack(alignment: .leading, spacing: .spacingSm) {
                    Text("Model Usage")
                        .font(.semanticSectionTitle)
                        .dynamicTypeScaled(font: .semanticSectionTitle)
                        .highContrastAdjusted(color: themeManager.currentTheme.secondaryText)
                        .padding(.leading, .spacingXs)
                        .accessibilityHeading(.h3)
                    
                    ModelProgressCollection(
                        breakdowns: session.modelBreakdown,
                        style: .standard
                    )
                }
                
                // Simple progress bar
                VStack(spacing: 3) {
                    // Removed redundant progress indicators as per UI feedback
                }
            }
        }
        .padding(.spacingLg)
        .background(themeManager.currentTheme.secondaryBackground)
        .cornerRadius(.cardRadius)
    }
    
    
    private var quickActionsView: some View {
        HStack(spacing: .spacing2) {
            // Live status first
            HStack(spacing: .spacingXs) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Live")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Icon buttons - cohesive filled circle style
            Button {
                do {
                    usageManager.exportData()
                } catch {
                    print("❌ Export failed: \(error)")
                }
            } label: {
                Image(systemName: "arrow.up.doc.fill")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Export usage data")
            .accessibilityHint("Export current usage data to file")
            
            Button {
                do {
                    print("🔧 Settings button clicked")
                    try openSettingsWindowSafely()
                } catch {
                    print("❌ Settings window failed: \(error)")
                }
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Settings")
            .accessibilityHint("Open application settings")
            
            Button {
                do {
                    print("🚪 Quit button clicked")
                    NSApplication.shared.terminate(nil)
                } catch {
                    print("❌ Quit failed: \(error)")
                    // Force quit as backup
                    exit(0)
                }
            } label: {
                Image(systemName: "multiply.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Quit application")
            .accessibilityHint("Close ClaudeRadar")
        }
        .padding(.horizontal, .spacing3)
        .padding(.vertical, .spacing2)
    }
    
    
    // MARK: - Helper Methods
    
    private var filteredSessions: [ClaudeSession] {
        let now = Date()
        let sessions = usageManager.recentSessions
        
        switch selectedTimeRange {
        case .today:
            let startOfDay = Calendar.current.startOfDay(for: now)
            return sessions.filter { session in
                // Include active sessions that are currently running
                if session.isActive {
                    return true
                }
                // Include sessions that started today OR end today (for cross-midnight sessions)
                return session.startTime >= startOfDay || session.endTime >= startOfDay
            }
        case .week:
            let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return sessions.filter { $0.startTime >= weekAgo }
        case .month:
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            return sessions.filter { $0.startTime >= monthAgo }
        }
    }
    
    private func progressColor(for count: Int, limit: Int) -> Color {
        let percentage = Double(count) / Double(limit)
        if percentage > 0.9 {
            return .statusCritical
        } else if percentage > 0.7 {
            return .statusWarning
        } else {
            return .statusSuccess
        }
    }
    
    private func timeRemainingText(for session: ClaudeSession) -> String {
        guard let burnRate = session.burnRate, burnRate > 0 else {
            return "N/A"
        }
        
        let remaining = session.tokenLimit - session.tokenCount
        let minutesRemaining = Double(remaining) / burnRate
        
        if minutesRemaining > 60 {
            return "\(Int(minutesRemaining / 60))h \(Int(minutesRemaining.truncatingRemainder(dividingBy: 60)))m"
        } else {
            return "\(Int(minutesRemaining))m"
        }
    }
    
    private var formattedUpdateTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.preferred
        return formatter.string(from: usageManager.lastUpdateTime)
    }
    
    private func openSettingsWindowSafely() throws {
        if let window = NSApp.windows.first(where: { $0.title == "ClaudeRadar Settings" }) {
            window.makeKeyAndOrderFront(nil)
            return
        }
        
        let settingsView = SettingsView()
            .environmentObject(themeManager)
        
        let hostingController = NSHostingController(rootView: settingsView)
        
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 450),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        settingsWindow.title = "ClaudeRadar Settings"
        settingsWindow.minSize = NSSize(width: 500, height: 450)
        settingsWindow.contentViewController = hostingController
        settingsWindow.center()
        settingsWindow.makeKeyAndOrderFront(nil)
        
        print("✅ Settings window opened successfully")
    }
    
    private func openSettingsWindow() {
        // Legacy wrapper for compatibility
        do {
            try openSettingsWindowSafely()
        } catch {
            print("❌ Settings window failed: \(error)")
        }
    }
}

enum SettingsError: Error {
    case missingThemeManager
    case failedToCreateView
    case windowCreationFailed
    
    var localizedDescription: String {
        switch self {
        case .missingThemeManager:
            return "Theme manager not available"
        case .failedToCreateView:
            return "Failed to create settings view"
        case .windowCreationFailed:
            return "Failed to create settings window"
        }
    }
}

enum TimeRange: CaseIterable {
    case today, week, month
    
    var displayName: String {
        switch self {
        case .today: return "Today"
        case .week: return "Week"
        case .month: return "Month"
        }
    }
}

// MARK: - Compact Metric Component with Auto-Layout

struct CompactMetric: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: .spacingSm) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 20, alignment: .center)
            
            VStack(alignment: .leading, spacing: .spacingXs) {
                // First line: Label
                Text(label)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
                    .allowsTightening(true)
                
                // Parse value for 3-line display
                if value.contains("tokens/min") {
                    let components = value.replacingOccurrences(of: " tokens/min", with: "").components(separatedBy: " ")
                    if let number = components.first {
                        // Second line: Number
                        Text(number)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(nil)
                            .allowsTightening(true)
                        
                        // Third line: Unit
                        Text("tokens/min")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                            .lineLimit(nil)
                            .allowsTightening(true)
                    }
                } else if value.contains("PM") || value.contains("AM") {
                    // For time format "2:21 PM (1h 44m)"
                    let components = value.components(separatedBy: " (")
                    if components.count >= 2 {
                        // Second line: Time
                        Text(components[0])
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(nil)
                            .allowsTightening(true)
                        
                        // Third line: Duration
                        Text("(\(components[1])")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                            .lineLimit(nil)
                            .allowsTightening(true)
                    }
                } else {
                    // Fallback for other formats
                    Text(value)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .allowsTightening(true)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, .spacingMd)
        .padding(.vertical, .spacingSm)
        .background(Color.backgroundSecondary)
        .cornerRadius(.cornerRadiusMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}