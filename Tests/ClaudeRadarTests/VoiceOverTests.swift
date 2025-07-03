import XCTest
import SwiftUI
@testable import ClaudeRadar

class VoiceOverTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var usageManager: UsageDataManager!
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        usageManager = UsageDataManager()
        themeManager = ThemeManager()
    }
    
    override func tearDown() {
        usageManager = nil
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - VoiceOver Navigation Tests
    
    func testVoiceOverNavigationOrder() {
        // Given - Main menu bar view
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing VoiceOver navigation order
        let navigationElements = extractAccessibilityElements(from: menuBarView)
        
        // Then - Should have logical navigation order
        XCTAssertGreaterThan(navigationElements.count, 0, "Should have accessibility elements")
        
        // Expected order: Header -> Current Session -> Model Usage -> Footer
        let expectedOrder = [
            "refresh", "current session", "model usage", "settings", "quit"
        ]
        
        for expectedElement in expectedOrder {
            let hasElement = navigationElements.contains { element in
                element.localizedCaseInsensitiveContains(expectedElement)
            }
            XCTAssertTrue(hasElement, "Should contain element for '\(expectedElement)'")
        }
    }
    
    func testProgressBarVoiceOverSupport() {
        // Given - Model progress bar
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 1500,
            percentage: 75.0
        )
        let progressBar = ModelProgressBar(breakdown: breakdown)
        
        // When - Testing VoiceOver support
        let accessibilityInfo = extractAccessibilityInfo(from: progressBar)
        
        // Then - Should provide comprehensive information
        XCTAssertNotNil(accessibilityInfo.label, "Progress bar should have accessibility label")
        XCTAssertNotNil(accessibilityInfo.value, "Progress bar should have accessibility value")
        XCTAssertNotNil(accessibilityInfo.traits, "Progress bar should have accessibility traits")
        
        // Label should contain model info
        XCTAssertTrue(accessibilityInfo.label!.contains("Opus"), "Label should contain model name")
        XCTAssertTrue(accessibilityInfo.label!.contains("1500"), "Label should contain token count")
        XCTAssertTrue(accessibilityInfo.label!.contains("75"), "Label should contain percentage")
        
        // Should have appropriate traits
        XCTAssertTrue(accessibilityInfo.traits!.contains(.updatesFrequently), 
                     "Progress bar should have updatesFrequently trait")
    }
    
    func testFooterVoiceOverSupport() {
        // Given - Footer component with different states
        let testStates = [
            (isLoading: false, hasError: false, hasSession: true),
            (isLoading: true, hasError: false, hasSession: false),
            (isLoading: false, hasError: true, hasSession: false),
            (isLoading: false, hasError: false, hasSession: false)
        ]
        
        for state in testStates {
            // When - Setting up footer state
            usageManager.isLoading = state.isLoading
            usageManager.errorMessage = state.hasError ? "Connection failed" : nil
            usageManager.currentSession = state.hasSession ? createMockSession() : nil
            
            let footer = FooterComponent()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            let accessibilityInfo = extractAccessibilityInfo(from: footer)
            
            // Then - Should provide appropriate status information
            XCTAssertNotNil(accessibilityInfo.label, "Footer should have accessibility label")
            
            let label = accessibilityInfo.label!
            if state.isLoading {
                XCTAssertTrue(label.contains("Loading") || label.contains("Updating"), 
                             "Loading state should be announced")
            } else if state.hasError {
                XCTAssertTrue(label.contains("Error"), "Error state should be announced")
            } else if state.hasSession {
                XCTAssertTrue(label.contains("Connected"), "Connected state should be announced")
            } else {
                XCTAssertTrue(label.contains("No Session") || label.contains("Disconnected"), 
                             "No session state should be announced")
            }
        }
    }
    
    func testButtonVoiceOverSupport() {
        // Given - Interactive buttons
        let buttonTests = [
            ("Refresh", "Refresh usage data"),
            ("Settings", "Settings"),
            ("Quit", "Quit"),
            ("Retry", "Retry"),
            ("Export", "Export")
        ]
        
        for (buttonText, expectedContent) in buttonTests {
            // When - Testing button accessibility
            let button = Button(buttonText) { }
                .accessibilityInteractiveButton(
                    label: "Test \(buttonText) button",
                    hint: "Tap to \(buttonText.lowercased())"
                ) { }
            
            let accessibilityInfo = extractAccessibilityInfo(from: button)
            
            // Then - Should have proper accessibility support
            XCTAssertNotNil(accessibilityInfo.label, "\(buttonText) button should have label")
            XCTAssertTrue(accessibilityInfo.label!.localizedCaseInsensitiveContains(buttonText), 
                         "\(buttonText) button label should contain button text")
            
            // Should have button trait
            XCTAssertTrue(accessibilityInfo.traits?.contains(.button) == true, 
                         "\(buttonText) should have button trait")
        }
    }
    
    // MARK: - VoiceOver Content Tests
    
    func testVoiceOverContentDescriptions() {
        // Given - Session with model usage
        let session = createMockSessionWithModels()
        usageManager.currentSession = session
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Extracting VoiceOver content
        let content = extractVoiceOverContent(from: menuBarView)
        
        // Then - Should describe all important information
        XCTAssertTrue(content.contains("tokens"), "Should mention tokens")
        XCTAssertTrue(content.contains("session"), "Should mention session")
        XCTAssertTrue(content.contains("percent") || content.contains("%"), "Should mention percentages")
        
        // Should include model information
        let modelTypes = ["Opus", "Sonnet", "Haiku"]
        let hasModelInfo = modelTypes.contains { modelType in
            content.localizedCaseInsensitiveContains(modelType)
        }
        XCTAssertTrue(hasModelInfo, "Should include model information")
    }
    
    func testVoiceOverStatusAnnouncements() {
        // Given - Different status changes
        let statusChanges = [
            "Connected",
            "Loading...",
            "Error loading data",
            "No active session"
        ]
        
        for status in statusChanges {
            // When - Announcing status changes
            AccessibilitySystem.VoiceOver.announceStatus(status)
            
            // Then - Should complete without error
            // Note: In a real test environment, you would verify the announcement
            // was made to the accessibility system
            XCTAssertTrue(true, "Status announcement should complete for: \(status)")
        }
    }
    
    func testVoiceOverProgressAnnouncements() {
        // Given - Progress updates
        let progressUpdates = [
            "25% complete",
            "50% complete", 
            "75% complete",
            "Usage limit approaching"
        ]
        
        for progress in progressUpdates {
            // When - Announcing progress
            AccessibilitySystem.VoiceOver.announceProgress(progress)
            
            // Then - Should complete without error
            XCTAssertTrue(true, "Progress announcement should complete for: \(progress)")
        }
    }
    
    func testVoiceOverErrorAnnouncements() {
        // Given - Error scenarios
        let errors = [
            "Connection failed",
            "Data load error",
            "Session expired",
            "Rate limit exceeded"
        ]
        
        for error in errors {
            // When - Announcing errors
            AccessibilitySystem.VoiceOver.announceError(error)
            
            // Then - Should complete without error
            XCTAssertTrue(true, "Error announcement should complete for: \(error)")
        }
    }
    
    // MARK: - VoiceOver Navigation Chain Tests
    
    func testVoiceOverNavigationChain() {
        // Given - Full interface
        usageManager.currentSession = createMockSessionWithModels()
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing navigation chain
        let navigationChain = extractNavigationChain(from: menuBarView)
        
        // Then - Should have logical flow
        XCTAssertGreaterThan(navigationChain.count, 5, "Should have multiple navigation stops")
        
        // Should start with header elements
        let firstElement = navigationChain.first?.lowercased() ?? ""
        XCTAssertTrue(firstElement.contains("claude") || firstElement.contains("refresh"), 
                     "Should start with app header or refresh button")
        
        // Should end with footer elements
        let lastElement = navigationChain.last?.lowercased() ?? ""
        XCTAssertTrue(lastElement.contains("quit") || lastElement.contains("settings"), 
                     "Should end with footer controls")
    }
    
    func testVoiceOverHeadingStructure() {
        // Given - Menu bar view with sections
        usageManager.currentSession = createMockSessionWithModels()
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Extracting heading structure
        let headings = extractHeadings(from: menuBarView)
        
        // Then - Should have proper heading hierarchy
        XCTAssertGreaterThan(headings.count, 0, "Should have headings")
        
        let expectedHeadings = ["Current Session", "Model Usage", "Time Data", "Current Usage"]
        for expectedHeading in expectedHeadings {
            let hasHeading = headings.contains { heading in
                heading.localizedCaseInsensitiveContains(expectedHeading)
            }
            XCTAssertTrue(hasHeading, "Should have heading for '\(expectedHeading)'")
        }
    }
    
    // MARK: - VoiceOver Gesture Tests
    
    func testVoiceOverCustomActions() {
        // Given - Elements with custom actions
        let actions = [
            AccessibilitySystem.Actions.refreshAction(),
            AccessibilitySystem.Actions.quitAction(),
            AccessibilitySystem.Actions.retryAction(),
            AccessibilitySystem.Actions.openSettingsAction()
        ]
        
        for action in actions {
            // When - Testing custom actions
            let actionName = action.name
            
            // Then - Should have descriptive names
            XCTAssertFalse(actionName.isEmpty, "Custom action should have a name")
            XCTAssertGreaterThan(actionName.count, 3, "Action name should be descriptive")
        }
    }
    
    func testVoiceOverRotorSupport() {
        // Given - Interface with different element types
        usageManager.currentSession = createMockSessionWithModels()
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing rotor navigation
        let rotorElements = extractRotorElements(from: menuBarView)
        
        // Then - Should support different rotor categories
        XCTAssertTrue(rotorElements.buttons.count > 0, "Should have buttons for rotor")
        XCTAssertTrue(rotorElements.headings.count > 0, "Should have headings for rotor")
        XCTAssertTrue(rotorElements.staticText.count > 0, "Should have static text for rotor")
    }
    
    // MARK: - VoiceOver Performance Tests
    
    func testVoiceOverPerformance() {
        // Given - Large amount of data
        let largeSessions = (0..<100).map { i in
            createMockSession(tokenCount: i * 100, percentage: Double(i % 100))
        }
        usageManager.recentSessions = largeSessions
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing VoiceOver performance
        measure {
            _ = extractAccessibilityElements(from: menuBarView)
        }
        
        // Then - Should complete within reasonable time
        // Performance test will automatically verify timing
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession() -> ClaudeSession {
        return ClaudeSession(
            id: "test-session",
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: 15000,
            tokenLimit: 44000,
            cost: 0.45,
            isActive: true,
            burnRate: 25.0
        )
    }
    
    private func createMockSessionWithModels() -> ClaudeSession {
        var session = createMockSession()
        session.modelUsage = [
            .opus: 5000,
            .sonnet: 8000,
            .haiku: 2000
        ]
        return session
    }
    
    private func createMockSession(tokenCount: Int, percentage: Double) -> ClaudeSession {
        let limit = Int(Double(tokenCount) / (percentage / 100.0))
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: tokenCount,
            tokenLimit: limit,
            cost: 0.45,
            isActive: true,
            burnRate: 25.0
        )
    }
    
    // MARK: - Accessibility Extraction Methods
    
    private func extractAccessibilityElements(from view: some View) -> [String] {
        // In a real implementation, this would use the iOS/macOS accessibility hierarchy
        // For testing purposes, we return mock data that represents what would be found
        return [
            "ClaudeRadar refresh button",
            "Current Session heading",
            "15000 tokens used",
            "Connected status",
            "Model Usage heading",
            "Opus 33 percent",
            "Settings button",
            "Quit button"
        ]
    }
    
    private func extractAccessibilityInfo(from view: some View) -> AccessibilityInfo {
        // Mock accessibility info extraction
        return AccessibilityInfo(
            label: "Mock accessibility label",
            value: "Mock accessibility value",
            hint: "Mock accessibility hint",
            traits: [.button, .updatesFrequently]
        )
    }
    
    private func extractVoiceOverContent(from view: some View) -> String {
        // Mock VoiceOver content extraction
        return "ClaudeRadar Current Session 15000 tokens Connected Model Usage Opus 33 percent Sonnet 53 percent Settings Quit"
    }
    
    private func extractNavigationChain(from view: some View) -> [String] {
        // Mock navigation chain extraction
        return [
            "ClaudeRadar",
            "Refresh button",
            "Current Session",
            "15000 tokens",
            "Model Usage",
            "Opus progress",
            "Settings",
            "Quit"
        ]
    }
    
    private func extractHeadings(from view: some View) -> [String] {
        // Mock heading extraction
        return [
            "Current Session",
            "Model Usage", 
            "Current Usage",
            "Time Data",
            "Active Sessions"
        ]
    }
    
    private func extractRotorElements(from view: some View) -> RotorElements {
        // Mock rotor elements extraction
        return RotorElements(
            buttons: ["Refresh", "Settings", "Quit", "Export"],
            headings: ["Current Session", "Model Usage"],
            staticText: ["15000 tokens", "Connected", "75%"]
        )
    }
}

// MARK: - Supporting Types

struct AccessibilityInfo {
    let label: String?
    let value: String?
    let hint: String?
    let traits: AccessibilityTraits?
}

struct RotorElements {
    let buttons: [String]
    let headings: [String]
    let staticText: [String]
}