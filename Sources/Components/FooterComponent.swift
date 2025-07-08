import SwiftUI
import Foundation

// MARK: - Footer Component

struct FooterComponent: View {
    @EnvironmentObject var usageManager: UsageDataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: .spacingXs) {
            // Live status indicator
            statusIndicator
            updateTimeText
        }
        .padding(.horizontal, .spacingLg)
        .padding(.vertical, .spacingSm)
    }
    
    // MARK: - Status Indicator
    
    private var statusIndicator: some View {
        HStack(spacing: .spacingXs) {
            Circle()
                .fill(footerState.statusColor)
                .frame(width: 8, height: 8)
                // No animation for live status updates
            
            // No spinning indicator for live updates - status dot shows connection state
        }
        .accessibilityStatus(
            status: footerState.statusMessage,
            isActive: footerState.hasActiveSession
        )
    }
    
    // MARK: - Update Time Text
    
    private var updateTimeText: some View {
        Text(updateTimeDisplay)
            .font(.semanticFootnote)
            .foregroundColor(themeManager.currentTheme.tertiaryText)
            .accessibilityLabel("Last updated \(updateTimeDisplay)")
            .dynamicTypeScaled(font: .semanticFootnote)
            .highContrastAdjusted(color: themeManager.currentTheme.tertiaryText)
    }
    
    
    // MARK: - Computed Properties
    
    private var footerState: FooterState {
        FooterState(
            isLoading: usageManager.isLoading,
            hasError: usageManager.errorMessage != nil,
            hasActiveSession: usageManager.currentSession != nil,
            lastUpdateTime: usageManager.lastUpdateTime
        )
    }
    
    private var updateTimeDisplay: String {
        // Show "Live" when actively monitoring, only show timestamp if no data for > 1 minute
        if usageManager.isMonitoring {
            let timeSinceUpdate = Date().timeIntervalSince(usageManager.lastUpdateTime)
            if timeSinceUpdate < 60 { // Within 1 minute = still live
                return "Live"
            }
        }
        
        // Show last update time only when monitoring stopped or data is stale (> 1 minute)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.preferred
        return "Updated \(formatter.string(from: usageManager.lastUpdateTime))"
    }
}

// MARK: - Footer State

struct FooterState {
    let isLoading: Bool
    let hasError: Bool
    let hasActiveSession: Bool
    let lastUpdateTime: Date
    
    // MARK: - Computed Properties
    
    var isConnected: Bool {
        !isLoading && !hasError && isRecentUpdate
    }
    
    var isRecentUpdate: Bool {
        Date().timeIntervalSince(lastUpdateTime) < 300 // 5 minutes
    }
    
    var statusColor: Color {
        if isLoading {
            return .statusInfo
        } else if hasError {
            return .statusCritical
        } else if hasActiveSession && isConnected {
            return .statusSuccess
        } else if isConnected {
            return .statusNeutral
        } else {
            return .statusCritical
        }
    }
    
    var statusMessage: String {
        if isLoading {
            return "Loading..."
        } else if hasError {
            return "Error"
        } else if hasActiveSession && isConnected {
            return "Connected"
        } else if isConnected {
            return "No Session"
        } else {
            return "Disconnected"
        }
    }
    
    var accessibilityLabel: String {
        let timeDescription = isLoading ? "Updating" : "Last updated \(formatRelativeTime())"
        return "\(statusMessage) - \(timeDescription)"
    }
    
    var showRetryButton: Bool {
        hasError && !isLoading
    }
    
    // MARK: - Helper Methods
    
    private func formatRelativeTime() -> String {
        let interval = Date().timeIntervalSince(lastUpdateTime)
        let seconds = Int(abs(interval))
        
        if seconds < 60 {
            return "\(seconds) seconds ago"
        } else if seconds < 3600 {
            return "\(seconds / 60) minutes ago"
        } else if seconds < 86400 {
            return "\(seconds / 3600) hours ago"
        } else {
            return "\(seconds / 86400) days ago"
        }
    }
}

// MARK: - Footer Preview

#if DEBUG
struct FooterComponent_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Connected state
            FooterComponent()
                .environmentObject(createMockUsageManager(isLoading: false, hasError: false, hasSession: true))
                .environmentObject(ThemeManager())
                .previewDisplayName("Connected")
            
            // Loading state
            FooterComponent()
                .environmentObject(createMockUsageManager(isLoading: true, hasError: false, hasSession: false))
                .environmentObject(ThemeManager())
                .previewDisplayName("Loading")
            
            // Error state
            FooterComponent()
                .environmentObject(createMockUsageManager(isLoading: false, hasError: true, hasSession: false))
                .environmentObject(ThemeManager())
                .previewDisplayName("Error")
            
            // No session state
            FooterComponent()
                .environmentObject(createMockUsageManager(isLoading: false, hasError: false, hasSession: false))
                .environmentObject(ThemeManager())
                .previewDisplayName("No Session")
        }
        .frame(width: DesignTokens.Layout.menuBarWidth, height: 60)
    }
    
    private static func createMockUsageManager(isLoading: Bool, hasError: Bool, hasSession: Bool) -> UsageDataManager {
        let manager = UsageDataManager.shared
        manager.isLoading = isLoading
        manager.errorMessage = hasError ? "Connection failed" : nil
        manager.currentSession = hasSession ? createMockSession() : nil
        manager.lastUpdateTime = Date().addingTimeInterval(isLoading ? 0 : -60)
        return manager
    }
    
    private static func createMockSession() -> ClaudeSession {
        return ClaudeSession(
            id: "preview-session",
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: 15000,
            tokenLimit: 44000,
            cost: 0.45,
            isActive: true,
            burnRate: 25.0
        )
    }
}
#endif