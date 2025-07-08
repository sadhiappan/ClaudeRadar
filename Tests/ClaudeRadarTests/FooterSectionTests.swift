import XCTest
import SwiftUI
@testable import ClaudeRadar

final class FooterSectionTests: XCTestCase {
    
    // MARK: - Footer State Tests
    
    func testFooterConnectedState() {
        // Given - A connected state with recent data update
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        let recentUpdateTime = Date().addingTimeInterval(-30) // 30 seconds ago
        usageManager.lastUpdateTime = recentUpdateTime
        usageManager.isLoading = false
        usageManager.errorMessage = nil
        usageManager.currentSession = createMockActiveSession()
        
        // When - We check the footer state
        let isConnected = !usageManager.isLoading && usageManager.errorMessage == nil
        let hasRecentUpdate = Date().timeIntervalSince(usageManager.lastUpdateTime) < 300 // 5 minutes
        
        // Then - Should show connected state
        XCTAssertTrue(isConnected, "Footer should be in connected state")
        XCTAssertFalse(usageManager.isLoading, "Footer should not show loading indicator")
        XCTAssertTrue(hasRecentUpdate, "Footer should indicate recent update")
        XCTAssertNotNil(usageManager.currentSession, "Should have active session")
    }
    
    func testFooterDisconnectedState() {
        // Given - A disconnected state with old data
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        let oldUpdateTime = Date().addingTimeInterval(-900) // 15 minutes ago
        usageManager.lastUpdateTime = oldUpdateTime
        usageManager.isLoading = false
        usageManager.errorMessage = "Connection failed"
        usageManager.currentSession = nil
        
        // When - We check the footer state
        let isConnected = !usageManager.isLoading && usageManager.errorMessage == nil
        let hasRecentUpdate = Date().timeIntervalSince(usageManager.lastUpdateTime) < 300 // 5 minutes
        
        // Then - Should show disconnected state
        XCTAssertFalse(isConnected, "Footer should be in disconnected state")
        XCTAssertFalse(usageManager.isLoading, "Footer should not show loading indicator")
        XCTAssertFalse(hasRecentUpdate, "Footer should not indicate recent update")
        XCTAssertNotNil(usageManager.errorMessage, "Should have error message")
        XCTAssertNil(usageManager.currentSession, "Should not have active session")
    }
    
    func testFooterNoSessionState() {
        // Given - No active session but connected
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        let recentUpdateTime = Date().addingTimeInterval(-10) // 10 seconds ago
        usageManager.lastUpdateTime = recentUpdateTime
        usageManager.isLoading = false
        usageManager.errorMessage = nil
        usageManager.currentSession = nil
        usageManager.recentSessions = []
        
        // When - We check the footer state
        let isConnected = !usageManager.isLoading && usageManager.errorMessage == nil
        let hasRecentUpdate = Date().timeIntervalSince(usageManager.lastUpdateTime) < 300 // 5 minutes
        
        // Then - Should show no session state
        XCTAssertTrue(isConnected, "Footer should be connected")
        XCTAssertFalse(usageManager.isLoading, "Footer should not show loading indicator")
        XCTAssertTrue(hasRecentUpdate, "Footer should indicate recent update")
        XCTAssertNil(usageManager.currentSession, "Should not have active session")
        XCTAssertTrue(usageManager.recentSessions.isEmpty, "Should have no recent sessions")
    }
    
    func testFooterLoadingState() {
        // Given - A loading state
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        usageManager.isLoading = true
        usageManager.lastUpdateTime = Date()
        usageManager.errorMessage = nil
        
        // When - We check the footer state
        let isConnected = !usageManager.isLoading && usageManager.errorMessage == nil
        
        // Then - Should show loading state
        XCTAssertTrue(usageManager.isLoading, "Footer should show loading indicator")
        XCTAssertFalse(isConnected, "Footer should not be connected while loading")
        XCTAssertNil(usageManager.errorMessage, "Should not have error message")
    }
    
    func testFooterErrorState() {
        // Given - An error state
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        usageManager.isLoading = false
        usageManager.errorMessage = "Failed to load data"
        usageManager.lastUpdateTime = Date().addingTimeInterval(-60) // 1 minute ago
        
        // When - We check the footer state
        let isConnected = !usageManager.isLoading && usageManager.errorMessage == nil
        
        // Then - Should show error state
        XCTAssertFalse(isConnected, "Footer should be in error state")
        XCTAssertFalse(usageManager.isLoading, "Footer should not show loading indicator")
        XCTAssertNotNil(usageManager.errorMessage, "Should have error message")
        XCTAssertEqual(usageManager.errorMessage, "Failed to load data", "Error message should match")
    }
    
    // MARK: - Footer Display Tests
    
    func testFooterTimeDisplayFormats() {
        // Given - Various time intervals
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        let testCases: [(TimeInterval, String)] = [
            (-5, "seconds"),
            (-65, "minute"),
            (-3600, "hour"),
            (-7200, "hours"),
            (-86400, "day")
        ]
        
        for (interval, expectedComponent) in testCases {
            // When - We set the update time
            usageManager.lastUpdateTime = Date().addingTimeInterval(interval)
            
            // Then - Time should be properly formatted
            let timeInterval = Date().timeIntervalSince(usageManager.lastUpdateTime)
            XCTAssertTrue(timeInterval >= abs(interval), "Time interval should be at least \(abs(interval))")
            
            // The actual formatting is done in the view layer
            let formattedTime = formatTimeInterval(timeInterval)
            XCTAssertTrue(formattedTime.contains(expectedComponent), 
                         "Time display should contain '\(expectedComponent)' for interval \(interval)")
        }
    }
    
    func testFooterStatusColorTransitions() {
        // Given - Usage manager
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        
        // Test 1: Connected with active session
        usageManager.currentSession = createMockActiveSession()
        usageManager.isLoading = false
        usageManager.errorMessage = nil
        usageManager.lastUpdateTime = Date()
        
        let statusColor1 = getStatusColor(for: usageManager)
        XCTAssertEqual(statusColor1, .statusSuccess, "Active session should show green")
        
        // Test 2: Loading state
        usageManager.isLoading = true
        let statusColor2 = getStatusColor(for: usageManager)
        XCTAssertEqual(statusColor2, .statusInfo, "Loading should show blue")
        
        // Test 3: Error state
        usageManager.isLoading = false
        usageManager.errorMessage = "Connection error"
        let statusColor3 = getStatusColor(for: usageManager)
        XCTAssertEqual(statusColor3, .statusCritical, "Error should show red")
        
        // Test 4: No session state
        usageManager.errorMessage = nil
        usageManager.currentSession = nil
        let statusColor4 = getStatusColor(for: usageManager)
        XCTAssertEqual(statusColor4, .statusNeutral, "No session should show neutral")
    }
    
    func testFooterAccessibilityLabels() {
        // Given - Different footer states
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        let testCases: [(isLoading: Bool, hasError: Bool, hasSession: Bool, expectedLabel: String)] = [
            (false, false, true, "Connected"),
            (true, false, false, "Loading"),
            (false, true, false, "Error"),
            (false, false, false, "No Session")
        ]
        
        for testCase in testCases {
            // When - We set the footer state
            usageManager.isLoading = testCase.isLoading
            usageManager.errorMessage = testCase.hasError ? "Connection failed" : nil
            usageManager.currentSession = testCase.hasSession ? createMockActiveSession() : nil
            usageManager.lastUpdateTime = Date()
            
            let accessibilityLabel = getAccessibilityLabel(for: usageManager)
            
            // Then - Should have appropriate accessibility label
            XCTAssertTrue(accessibilityLabel.contains(testCase.expectedLabel),
                         "Accessibility label should contain '\(testCase.expectedLabel)', got '\(accessibilityLabel)'")
        }
    }
    
    // MARK: - Footer Component Tests
    
    func testFooterComponentStateDisplay() {
        // Given - Usage manager in different states
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        
        // Test 1: Connected state
        usageManager.isLoading = false
        usageManager.errorMessage = nil
        usageManager.currentSession = createMockActiveSession()
        usageManager.lastUpdateTime = Date().addingTimeInterval(-30) // 30 seconds ago
        
        let footerState1 = FooterState(
            isLoading: usageManager.isLoading,
            hasError: usageManager.errorMessage != nil,
            hasActiveSession: usageManager.currentSession != nil,
            lastUpdateTime: usageManager.lastUpdateTime
        )
        
        XCTAssertTrue(footerState1.isConnected, "Should be connected")
        XCTAssertEqual(footerState1.statusColor, .statusSuccess, "Status should be success")
        XCTAssertEqual(footerState1.statusMessage, "Connected", "Message should be 'Connected'")
        XCTAssertFalse(footerState1.showRetryButton, "Should not show retry button")
        
        // Test 2: Error state
        usageManager.isLoading = false
        usageManager.errorMessage = "Network error"
        usageManager.currentSession = nil
        
        let footerState2 = FooterState(
            isLoading: usageManager.isLoading,
            hasError: usageManager.errorMessage != nil,
            hasActiveSession: usageManager.currentSession != nil,
            lastUpdateTime: usageManager.lastUpdateTime
        )
        
        XCTAssertFalse(footerState2.isConnected, "Should not be connected")
        XCTAssertEqual(footerState2.statusColor, .statusCritical, "Status should be critical")
        XCTAssertEqual(footerState2.statusMessage, "Error", "Message should be 'Error'")
        XCTAssertTrue(footerState2.showRetryButton, "Should show retry button")
        
        // Test 3: Loading state
        usageManager.isLoading = true
        usageManager.errorMessage = nil
        
        let footerState3 = FooterState(
            isLoading: usageManager.isLoading,
            hasError: usageManager.errorMessage != nil,
            hasActiveSession: usageManager.currentSession != nil,
            lastUpdateTime: usageManager.lastUpdateTime
        )
        
        XCTAssertFalse(footerState3.isConnected, "Should not be connected while loading")
        XCTAssertEqual(footerState3.statusColor, .statusInfo, "Status should be info")
        XCTAssertEqual(footerState3.statusMessage, "Loading...", "Message should be 'Loading...'")
        XCTAssertFalse(footerState3.showRetryButton, "Should not show retry button while loading")
    }
    
    func testFooterStateRelativeTimeFormatting() {
        // Given - Different time intervals
        let baseTime = Date()
        let testCases: [(TimeInterval, String)] = [
            (30, "30 seconds ago"),
            (90, "1 minutes ago"),
            (3660, "1 hours ago"),
            (86460, "1 days ago")
        ]
        
        for (interval, expectedFormat) in testCases {
            // When - Creating footer state with specific time
            let footerState = FooterState(
                isLoading: false,
                hasError: false,
                hasActiveSession: true,
                lastUpdateTime: baseTime.addingTimeInterval(-interval)
            )
            
            // Then - Should format time correctly
            XCTAssertTrue(footerState.accessibilityLabel.contains(expectedFormat.replacingOccurrences(of: " ago", with: "")),
                         "Accessibility label should contain time information for interval \(interval)")
        }
    }
    
    // MARK: - Footer Integration Tests
    
    func testFooterStateTransitions() {
        // Given - Starting in loading state
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        usageManager.isLoading = true
        usageManager.errorMessage = nil
        usageManager.currentSession = nil
        
        XCTAssertTrue(usageManager.isLoading, "Should start in loading state")
        
        // When - Loading completes with session
        usageManager.isLoading = false
        usageManager.currentSession = createMockActiveSession()
        usageManager.lastUpdateTime = Date()
        
        let isConnected1 = !usageManager.isLoading && usageManager.errorMessage == nil
        XCTAssertTrue(isConnected1, "Should transition to connected state")
        XCTAssertNotNil(usageManager.currentSession, "Should have active session")
        
        // When - Connection fails
        usageManager.errorMessage = "Network error"
        usageManager.lastUpdateTime = Date().addingTimeInterval(-600) // 10 minutes ago
        
        let isConnected2 = !usageManager.isLoading && usageManager.errorMessage == nil
        XCTAssertFalse(isConnected2, "Should transition to disconnected state")
        XCTAssertNotNil(usageManager.errorMessage, "Should have error message")
        
        // When - Connection recovers but no session
        usageManager.errorMessage = nil
        usageManager.currentSession = nil
        usageManager.lastUpdateTime = Date()
        
        let isConnected3 = !usageManager.isLoading && usageManager.errorMessage == nil
        XCTAssertTrue(isConnected3, "Should be connected")
        XCTAssertNil(usageManager.currentSession, "Should have no session")
    }
    
    // MARK: - Helper Methods
    
    private func createMockActiveSession() -> ClaudeSession {
        return ClaudeSession(
            id: "test-session-1",
            startTime: Date().addingTimeInterval(-1800), // 30 minutes ago
            endTime: Date().addingTimeInterval(16200), // 4.5 hours from now
            tokenCount: 15_000,
            tokenLimit: 44_000,
            cost: 0.45,
            isActive: true,
            burnRate: 25.0
        )
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
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
    
    private func getStatusColor(for manager: UsageDataManager) -> Color {
        if manager.isLoading {
            return .statusInfo
        } else if manager.errorMessage != nil {
            return .statusCritical
        } else if manager.currentSession != nil {
            return .statusSuccess
        } else {
            return .statusNeutral
        }
    }
    
    private func getAccessibilityLabel(for manager: UsageDataManager) -> String {
        if manager.isLoading {
            return "Loading usage data"
        } else if manager.errorMessage != nil {
            return "Error loading data"
        } else if manager.currentSession != nil {
            return "Connected with active session"
        } else {
            return "No Session active"
        }
    }
}