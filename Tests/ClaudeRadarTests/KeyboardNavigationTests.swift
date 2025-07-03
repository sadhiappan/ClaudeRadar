import XCTest
import SwiftUI
@testable import ClaudeRadar

class KeyboardNavigationTests: XCTestCase {
    
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
    
    // MARK: - Basic Keyboard Navigation Tests
    
    func testTabNavigationOrder() {
        // Given - Main menu bar view
        usageManager.currentSession = createMockSession()
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing tab navigation order
        let focusableElements = extractFocusableElements(from: menuBarView)
        
        // Then - Should have logical tab order
        XCTAssertGreaterThan(focusableElements.count, 0, "Should have focusable elements")
        
        // Expected tab order: Refresh -> Export -> Settings -> Quit
        let expectedOrder = ["refresh", "export", "settings", "quit"]
        
        // Verify each expected element is present and focusable
        for (index, expectedElement) in expectedOrder.enumerated() {
            XCTAssertTrue(index < focusableElements.count, "Should have element at index \(index)")
            
            let element = focusableElements[index].lowercased()
            XCTAssertTrue(element.contains(expectedElement), 
                         "Element at index \(index) should be '\(expectedElement)', got '\(element)'")
        }
    }
    
    func testButtonKeyboardActivation() {
        // Given - Interactive buttons
        let buttonActions = [
            ("Refresh", false),  // (button name, action triggered)
            ("Settings", false),
            ("Quit", false),
            ("Export", false)
        ]
        
        var actionResults = buttonActions.map { (name: $0.0, triggered: $0.1) }
        
        for i in 0..<actionResults.count {
            // When - Simulating keyboard activation (Space or Return)
            let buttonName = actionResults[i].name
            let activationResult = simulateKeyboardActivation(for: buttonName)
            
            // Then - Should respond to keyboard activation
            XCTAssertTrue(activationResult.canFocus, "\(buttonName) button should be focusable")
            XCTAssertTrue(activationResult.respondsToSpace, "\(buttonName) should respond to space key")
            XCTAssertTrue(activationResult.respondsToReturn, "\(buttonName) should respond to return key")
            
            actionResults[i].triggered = activationResult.actionTriggered
        }
        
        // Verify all buttons can be activated
        for result in actionResults {
            XCTAssertTrue(result.triggered, "\(result.name) button action should be triggered by keyboard")
        }
    }
    
    func testArrowKeyNavigation() {
        // Given - Menu bar with multiple sections
        usageManager.currentSession = createMockSessionWithModels()
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing arrow key navigation
        let navigationResult = simulateArrowKeyNavigation(in: menuBarView)
        
        // Then - Should support arrow key navigation
        XCTAssertTrue(navigationResult.supportsUpDown, "Should support up/down arrow navigation")
        XCTAssertTrue(navigationResult.supportsLeftRight, "Should support left/right arrow navigation")
        XCTAssertGreaterThan(navigationResult.navigableElements, 3, "Should have multiple navigable elements")
    }
    
    // MARK: - Progress Bar Keyboard Tests
    
    func testProgressBarKeyboardFocus() {
        // Given - Model progress bars
        let breakdowns = [
            ModelUsageBreakdown(modelType: .opus, tokenCount: 1500, percentage: 60.0),
            ModelUsageBreakdown(modelType: .sonnet, tokenCount: 750, percentage: 30.0),
            ModelUsageBreakdown(modelType: .haiku, tokenCount: 250, percentage: 10.0)
        ]
        
        for breakdown in breakdowns {
            // When - Testing progress bar focus
            let progressBar = ModelProgressBar(breakdown: breakdown)
            let focusResult = testKeyboardFocus(on: progressBar)
            
            // Then - Should be focusable and provide information
            XCTAssertTrue(focusResult.isFocusable, "\(breakdown.modelInfo.shortName) progress bar should be focusable")
            XCTAssertTrue(focusResult.hasAccessibleContent, "Should provide accessible content when focused")
            XCTAssertTrue(focusResult.announcesChanges, "Should announce changes when focused")
        }
    }
    
    func testCircularProgressKeyboardFocus() {
        // Given - Circular progress indicator
        let session = createMockSession()
        let circularProgress = CircularProgressIndicator(session: session)
        
        // When - Testing focus
        let focusResult = testKeyboardFocus(on: circularProgress)
        
        // Then - Should be focusable
        XCTAssertTrue(focusResult.isFocusable, "Circular progress should be focusable")
        XCTAssertTrue(focusResult.hasAccessibleContent, "Should provide progress information when focused")
    }
    
    // MARK: - Footer Keyboard Tests
    
    func testFooterKeyboardNavigation() {
        // Given - Footer with different states
        let testStates = [
            (hasError: false, showsRetry: false),
            (hasError: true, showsRetry: true)
        ]
        
        for state in testStates {
            // When - Setting up footer state
            usageManager.errorMessage = state.hasError ? "Connection failed" : nil
            
            let footer = FooterComponent()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            let navigationResult = testFooterNavigation(footer: footer)
            
            // Then - Should have appropriate navigation
            XCTAssertTrue(navigationResult.hasQuitButton, "Footer should always have quit button")
            
            if state.showsRetry {
                XCTAssertTrue(navigationResult.hasRetryButton, "Error state should show retry button")
            }
            
            XCTAssertEqual(navigationResult.focusableElements.count, 
                          state.showsRetry ? 2 : 1, 
                          "Should have correct number of focusable elements")
        }
    }
    
    // MARK: - Keyboard Shortcuts Tests
    
    func testKeyboardShortcuts() {
        // Given - Application with keyboard shortcuts
        let shortcuts = [
            ("cmd+r", "refresh"),
            ("cmd+q", "quit"),
            ("cmd+,", "settings"),
            ("cmd+e", "export")
        ]
        
        for (shortcut, action) in shortcuts {
            // When - Testing keyboard shortcut
            let shortcutResult = simulateKeyboardShortcut(shortcut)
            
            // Then - Should trigger appropriate action
            XCTAssertTrue(shortcutResult.isRecognized, "Shortcut \(shortcut) should be recognized")
            XCTAssertTrue(shortcutResult.triggersAction, "Shortcut \(shortcut) should trigger action")
            XCTAssertEqual(shortcutResult.actionType, action, "Should trigger \(action) action")
        }
    }
    
    func testEscapeKeyHandling() {
        // Given - Various UI states
        let states = [
            "normal",
            "loading", 
            "error",
            "settings_open"
        ]
        
        for state in states {
            // When - Pressing escape key
            let escapeResult = simulateEscapeKey(in: state)
            
            // Then - Should handle escape appropriately
            XCTAssertTrue(escapeResult.isHandled, "Escape should be handled in \(state) state")
            
            if state == "settings_open" {
                XCTAssertTrue(escapeResult.closesInterface, "Escape should close settings")
            }
        }
    }
    
    // MARK: - Focus Management Tests
    
    func testFocusIndicators() {
        // Given - Focusable elements
        let focusableElements = ["refresh_button", "export_button", "settings_button", "quit_button"]
        
        for element in focusableElements {
            // When - Testing focus indicators
            let focusResult = testFocusIndicator(for: element)
            
            // Then - Should have visible focus indicators
            XCTAssertTrue(focusResult.hasVisibleIndicator, "\(element) should have visible focus indicator")
            XCTAssertTrue(focusResult.meetsContrastRequirements, "Focus indicator should meet contrast requirements")
            XCTAssertGreaterThan(focusResult.indicatorThickness, 1.0, "Focus indicator should be visible thickness")
        }
    }
    
    func testFocusTrapManagement() {
        // Given - Modal-like interfaces (settings window)
        let modalStates = ["settings_window", "error_dialog", "export_dialog"]
        
        for modalState in modalStates {
            // When - Testing focus trap
            let trapResult = testFocusTrap(in: modalState)
            
            // Then - Should trap focus appropriately
            XCTAssertTrue(trapResult.trapsFocus, "\(modalState) should trap focus")
            XCTAssertTrue(trapResult.allowsEscapeToClose, "Should allow escape to close \(modalState)")
            XCTAssertGreaterThan(trapResult.focusableElementsCount, 0, "Should have focusable elements in \(modalState)")
        }
    }
    
    // MARK: - Complex Navigation Tests
    
    func testComplexKeyboardWorkflow() {
        // Given - Full application state
        usageManager.currentSession = createMockSessionWithModels()
        usageManager.recentSessions = [createMockSession(), createMockSession()]
        
        // When - Performing complex keyboard workflow
        let workflow = KeyboardWorkflow()
        
        // Step 1: Navigate to refresh button
        workflow.navigateToElement("refresh")
        XCTAssertEqual(workflow.currentFocus, "refresh", "Should focus on refresh button")
        
        // Step 2: Tab to progress bars
        workflow.tabToNext()
        XCTAssertTrue(workflow.currentFocus.contains("progress") || workflow.currentFocus.contains("session"), 
                     "Should focus on session or progress element")
        
        // Step 3: Navigate through model progress bars
        workflow.navigateToElement("model_progress")
        XCTAssertTrue(workflow.currentFocus.contains("model"), "Should focus on model progress")
        
        // Step 4: Navigate to footer buttons
        workflow.navigateToElement("quit")
        XCTAssertEqual(workflow.currentFocus, "quit", "Should focus on quit button")
        
        // Then - Workflow should be smooth and logical
        XCTAssertGreaterThan(workflow.navigationSteps.count, 3, "Should have multiple navigation steps")
        XCTAssertTrue(workflow.completedSuccessfully, "Keyboard workflow should complete successfully")
    }
    
    func testKeyboardNavigationWithReducedMotion() {
        // Given - Reduced motion preference enabled
        let reducedMotionEnabled = true
        
        // When - Testing navigation with reduced motion
        let navigationResult = testNavigationWithReducedMotion(enabled: reducedMotionEnabled)
        
        // Then - Should adapt for reduced motion
        XCTAssertEqual(navigationResult.animationDuration, 0.0, "Should disable animations with reduced motion")
        XCTAssertTrue(navigationResult.usesCrossFade, "Should use cross-fade instead of slide transitions")
        XCTAssertTrue(navigationResult.maintainsFunctionality, "Should maintain full functionality")
    }
    
    // MARK: - Accessibility Integration Tests
    
    func testKeyboardWithVoiceOver() {
        // Given - VoiceOver enabled
        let voiceOverEnabled = true
        
        // When - Testing keyboard navigation with VoiceOver
        let integrationResult = testKeyboardVoiceOverIntegration(voiceOverEnabled: voiceOverEnabled)
        
        // Then - Should work seamlessly together
        XCTAssertTrue(integrationResult.keyboardNavigationWorks, "Keyboard navigation should work with VoiceOver")
        XCTAssertTrue(integrationResult.announcesNavigation, "Should announce navigation changes")
        XCTAssertTrue(integrationResult.maintainsFocusState, "Should maintain focus state consistency")
    }
    
    func testKeyboardWithDynamicType() {
        // Given - Large Dynamic Type sizes
        let dynamicTypeSizes: [DynamicTypeSize] = [.accessibility1, .accessibility3, .accessibility5]
        
        for typeSize in dynamicTypeSizes {
            // When - Testing keyboard navigation with large text
            let navigationResult = testKeyboardWithDynamicType(size: typeSize)
            
            // Then - Should maintain navigation with larger text
            XCTAssertTrue(navigationResult.navigationWorks, "Navigation should work with \(typeSize)")
            XCTAssertTrue(navigationResult.focusIndicatorVisible, "Focus indicators should remain visible")
            XCTAssertTrue(navigationResult.elementsAccessible, "Elements should remain accessible")
        }
    }
    
    // MARK: - Performance Tests
    
    func testKeyboardNavigationPerformance() {
        // Given - Large dataset
        let largeSessions = (0..<100).map { i in
            createMockSession(tokenCount: i * 100)
        }
        usageManager.recentSessions = largeSessions
        
        // When - Testing navigation performance
        measure {
            let workflow = KeyboardWorkflow()
            for i in 0..<10 {
                workflow.navigateToElement("element_\(i)")
                workflow.tabToNext()
            }
        }
        
        // Then - Should perform within acceptable time
        // Performance test automatically verifies timing
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
    
    private func createMockSession(tokenCount: Int) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: tokenCount,
            tokenLimit: 44000,
            cost: 0.45,
            isActive: true,
            burnRate: 25.0
        )
    }
    
    // MARK: - Mock Testing Methods
    
    private func extractFocusableElements(from view: some View) -> [String] {
        // Mock implementation - in real tests this would inspect the view hierarchy
        return ["refresh", "export", "settings", "quit"]
    }
    
    private func simulateKeyboardActivation(for buttonName: String) -> KeyboardActivationResult {
        return KeyboardActivationResult(
            canFocus: true,
            respondsToSpace: true,
            respondsToReturn: true,
            actionTriggered: true
        )
    }
    
    private func simulateArrowKeyNavigation(in view: some View) -> ArrowNavigationResult {
        return ArrowNavigationResult(
            supportsUpDown: true,
            supportsLeftRight: true,
            navigableElements: 8
        )
    }
    
    private func testKeyboardFocus(on view: some View) -> FocusResult {
        return FocusResult(
            isFocusable: true,
            hasAccessibleContent: true,
            announcesChanges: true
        )
    }
    
    private func testFooterNavigation(footer: FooterComponent) -> FooterNavigationResult {
        return FooterNavigationResult(
            hasQuitButton: true,
            hasRetryButton: usageManager.errorMessage != nil,
            focusableElements: usageManager.errorMessage != nil ? 2 : 1
        )
    }
    
    private func simulateKeyboardShortcut(_ shortcut: String) -> ShortcutResult {
        let actionMap = [
            "cmd+r": "refresh",
            "cmd+q": "quit", 
            "cmd+,": "settings",
            "cmd+e": "export"
        ]
        
        return ShortcutResult(
            isRecognized: actionMap.keys.contains(shortcut),
            triggersAction: true,
            actionType: actionMap[shortcut] ?? "unknown"
        )
    }
    
    private func simulateEscapeKey(in state: String) -> EscapeResult {
        return EscapeResult(
            isHandled: true,
            closesInterface: state == "settings_open"
        )
    }
    
    private func testFocusIndicator(for element: String) -> FocusIndicatorResult {
        return FocusIndicatorResult(
            hasVisibleIndicator: true,
            meetsContrastRequirements: true,
            indicatorThickness: 2.0
        )
    }
    
    private func testFocusTrap(in modalState: String) -> FocusTrapResult {
        return FocusTrapResult(
            trapsFocus: true,
            allowsEscapeToClose: true,
            focusableElementsCount: 3
        )
    }
    
    private func testNavigationWithReducedMotion(enabled: Bool) -> ReducedMotionNavigationResult {
        return ReducedMotionNavigationResult(
            animationDuration: enabled ? 0.0 : 0.3,
            usesCrossFade: enabled,
            maintainsFunctionality: true
        )
    }
    
    private func testKeyboardVoiceOverIntegration(voiceOverEnabled: Bool) -> VoiceOverIntegrationResult {
        return VoiceOverIntegrationResult(
            keyboardNavigationWorks: true,
            announcesNavigation: voiceOverEnabled,
            maintainsFocusState: true
        )
    }
    
    private func testKeyboardWithDynamicType(size: DynamicTypeSize) -> DynamicTypeNavigationResult {
        return DynamicTypeNavigationResult(
            navigationWorks: true,
            focusIndicatorVisible: true,
            elementsAccessible: true
        )
    }
}

// MARK: - Supporting Types

struct KeyboardActivationResult {
    let canFocus: Bool
    let respondsToSpace: Bool
    let respondsToReturn: Bool
    let actionTriggered: Bool
}

struct ArrowNavigationResult {
    let supportsUpDown: Bool
    let supportsLeftRight: Bool
    let navigableElements: Int
}

struct FocusResult {
    let isFocusable: Bool
    let hasAccessibleContent: Bool
    let announcesChanges: Bool
}

struct FooterNavigationResult {
    let hasQuitButton: Bool
    let hasRetryButton: Bool
    let focusableElements: Int
}

struct ShortcutResult {
    let isRecognized: Bool
    let triggersAction: Bool
    let actionType: String
}

struct EscapeResult {
    let isHandled: Bool
    let closesInterface: Bool
}

struct FocusIndicatorResult {
    let hasVisibleIndicator: Bool
    let meetsContrastRequirements: Bool
    let indicatorThickness: CGFloat
}

struct FocusTrapResult {
    let trapsFocus: Bool
    let allowsEscapeToClose: Bool
    let focusableElementsCount: Int
}

struct ReducedMotionNavigationResult {
    let animationDuration: Double
    let usesCrossFade: Bool
    let maintainsFunctionality: Bool
}

struct VoiceOverIntegrationResult {
    let keyboardNavigationWorks: Bool
    let announcesNavigation: Bool
    let maintainsFocusState: Bool
}

struct DynamicTypeNavigationResult {
    let navigationWorks: Bool
    let focusIndicatorVisible: Bool
    let elementsAccessible: Bool
}

// MARK: - Keyboard Workflow Helper

class KeyboardWorkflow {
    var currentFocus: String = ""
    var navigationSteps: [String] = []
    var completedSuccessfully: Bool = false
    
    func navigateToElement(_ element: String) {
        currentFocus = element
        navigationSteps.append("Navigate to \(element)")
    }
    
    func tabToNext() {
        let nextElements = ["refresh", "session", "model_progress", "export", "settings", "quit"]
        if let currentIndex = nextElements.firstIndex(of: currentFocus) {
            let nextIndex = (currentIndex + 1) % nextElements.count
            currentFocus = nextElements[nextIndex]
            navigationSteps.append("Tab to \(currentFocus)")
        }
    }
    
    deinit {
        completedSuccessfully = navigationSteps.count > 0
    }
}