import SwiftUI
import Charts

struct MenuBarView: View {
    @EnvironmentObject var usageManager: UsageDataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTimeRange: TimeRange = .today
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern Gradient Header
            CompleteGradientHeader(
                session: usageManager.currentSession,
                themeManager: themeManager,
                onRefresh: {
                    print("🔄 Refresh button clicked")
                    usageManager.refreshData()
                }
            )
            
            Divider().opacity(0.3)
            
            // Current Session Info
            currentSessionView
            
            Divider().opacity(0.5)
            
            // Usage Chart
            usageChartView
            
            Divider().opacity(0.5)
            
            // Quick Actions + Footer combined
            VStack(spacing: .spacingSm) {
                quickActionsView
                footerView
            }
        }
        .background(themeManager.currentTheme.background)
        .frame(width: DesignTokens.Layout.menuBarWidth)
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
                    .font(.semanticAppSubtitle)
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
            .buttonStyle(PlainButtonStyle())
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
                
                Spacer()
                
                if let session = usageManager.currentSession {
                    VStack(spacing: 1) {
                        CircularProgressView(
                            progress: Double(session.tokenCount) / Double(session.tokenLimit),
                            color: progressColor(for: session.tokenCount, limit: session.tokenLimit)
                        )
                        .frame(width: .progressCircleSize, height: .progressCircleSize)
                        
                        Text("\(Int(session.progress * 100))%")
                            .font(.metricLabel)
                            .dynamicTypeScaled(font: .metricLabel)
                            .highContrastAdjusted(color: .textSecondary)
                            .accessibilityLabel("Session progress: \(Int(session.progress * 100)) percent")
                    }
                }
            }
            
            // Improved metrics with flexible layout
            if let session = usageManager.currentSession {
                let layoutData = session.metricsLayoutData
                
                VStack(spacing: .spacing2) {
                    // Usage Metrics Group
                    VStack(alignment: .leading, spacing: .spacing1) {
                        Text("Current Usage")
                            .font(.metricLabel)
                            .dynamicTypeScaled(font: .metricLabel)
                            .highContrastAdjusted(color: .textSecondary)
                            .padding(.leading, .spacing1)
                            .accessibilityHeading(.h3)
                        
                        HStack(spacing: .spacing2) {
                            CompactMetric(
                                icon: "flame.fill",
                                color: .accentOrange,
                                label: "Rate",
                                value: layoutData.burnRateDisplay
                            )
                            
                            CompactMetric(
                                icon: "gauge.high",
                                color: progressColor(for: session.tokenCount, limit: session.tokenLimit),
                                label: "Used",
                                value: "\(Int(session.progress * 100))%"
                            )
                        }
                    }
                    
                    // Time Data Group
                    VStack(alignment: .leading, spacing: .spacing1) {
                        Text("Time Data")
                            .font(.metricLabel)
                            .dynamicTypeScaled(font: .metricLabel)
                            .highContrastAdjusted(color: .textSecondary)
                            .padding(.leading, .spacing1)
                            .accessibilityHeading(.h3)
                        
                        HStack(spacing: .spacing2) {
                            CompactMetric(
                                icon: "clock.fill",
                                color: .accentBlue,
                                label: "Left",
                                value: layoutData.timeRemainingDisplay
                            )
                            
                            CompactMetric(
                                icon: "clock.badge.checkmark",
                                color: .accentGreen,
                                label: "Ends",
                                value: layoutData.sessionEndDisplay
                            )
                        }
                    }
                }
                
                // Model Usage Breakdown
                if !session.modelBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: .spacingSm) {
                        Text("Model Usage")
                            .font(.semanticSectionTitle)
                            .dynamicTypeScaled(font: .semanticSectionTitle)
                            .highContrastAdjusted(color: themeManager.currentTheme.secondaryText)
                            .padding(.leading, .spacingXs)
                            .accessibilityHeading(.h3)
                        
                        ModelProgressCollection(
                            breakdowns: session.modelBreakdown,
                            style: .compact
                        )
                    }
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
    
    @ViewBuilder
    private var usageChartView: some View {
        // Show active sessions overview instead of meaningless trend
        let activeSessions = usageManager.recentSessions.filter { $0.isActive }
        
        if !activeSessions.isEmpty {
            VStack(alignment: .leading, spacing: .spacing1) {
                HStack {
                    Text("Active Sessions")
                        .font(.metricLabel)
                        .dynamicTypeScaled(font: .metricLabel)
                        .highContrastAdjusted(color: .textSecondary)
                        .accessibilityHeading(.h2)
                    
                    Spacer()
                    
                    Text("\(activeSessions.count) active")
                        .font(.footerText)
                        .foregroundColor(.accentBlue)
                }
                
                // Show session progress bars for active sessions
                VStack(spacing: .spacing1) {
                    ForEach(activeSessions.prefix(3)) { session in
                        HStack(spacing: .spacing2) {
                            // Session indicator
                            Circle()
                                .fill(progressColor(for: session.tokenCount, limit: session.tokenLimit))
                                .frame(width: 6, height: 6)
                            
                            // Session info
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text("\(session.tokenCount) / \(session.tokenLimit)")
                                        .font(.footerText)
                                        .foregroundColor(.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(session.progress * 100))%")
                                        .font(.footerText)
                                        .foregroundColor(.textSecondary)
                                }
                                
                                // Mini progress bar
                                ProgressView(value: session.progress)
                                    .progressViewStyle(LinearProgressViewStyle(
                                        tint: progressColor(for: session.tokenCount, limit: session.tokenLimit)
                                    ))
                                    .frame(height: 2)
                            }
                        }
                    }
                    
                    if activeSessions.count > 3 {
                        Text("+ \(activeSessions.count - 3) more sessions")
                            .font(.footerText)
                            .foregroundColor(.textSecondary)
                            .padding(.leading, .spacing3)
                    }
                }
            }
            .padding(.spacing2)
        }
    }
    
    private var quickActionsView: some View {
        HStack {
            Button("Export") {
                usageManager.exportData()
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityInteractiveButton(
                label: "Export usage data",
                hint: "Export current usage data to file"
            ) {
                usageManager.exportData()
            }
            .keyboardNavigable {
                usageManager.exportData()
            }
            
            Spacer()
            
            Button("Settings") {
                print("🔧 Settings button clicked")
                // TODO: Move to WindowManager service
                openSettingsWindow()
            }
            .buttonStyle(TertiaryButtonStyle())
            .accessibilityInteractiveButton(
                label: AccessibilitySystem.Labels.settingsButtonLabel(),
                hint: AccessibilitySystem.Hints.settingsButton
            ) {
                openSettingsWindow()
            }
            .keyboardNavigable {
                openSettingsWindow()
            }
        }
        .padding(.horizontal, .spacing3)
        .padding(.top, .spacing2)
    }
    
    private var footerView: some View {
        FooterComponent()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
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
    
    private func openSettingsWindow() {
        if let window = NSApp.windows.first(where: { $0.title == "Settings" }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            let fittingSize = hostingController.view.fittingSize
            let dynamicSize = NSSize(
                width: max(fittingSize.width, 500),
                height: max(fittingSize.height, 450)
            )
            let settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: dynamicSize.width, height: dynamicSize.height),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow.title = "ClaudeRadar Settings"
            settingsWindow.minSize = NSSize(width: 500, height: 450)
            settingsWindow.contentViewController = hostingController
            settingsWindow.center()
            settingsWindow.makeKeyAndOrderFront(nil)
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
        HStack(spacing: .spacing2) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.footnote)
                .frame(width: .iconFrameSize)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.metricLabel)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(value)
                    .font(.metricValue)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, .spacing2)
        .padding(.vertical, .spacing1)
        .background(Color.backgroundSecondary)
        .cornerRadius(.cornerRadiusMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}