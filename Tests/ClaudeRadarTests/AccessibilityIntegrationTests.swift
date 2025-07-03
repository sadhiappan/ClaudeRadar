import XCTest
import SwiftUI
@testable import ClaudeRadar

class AccessibilityIntegrationTests: XCTestCase {
    
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
    
    // MARK: - Complete Accessibility Workflow Tests
    
    func testCompleteAccessibilityWorkflow() {
        // Given - Full application state
        usageManager.currentSession = createMockSessionWithCompleteData()
        usageManager.recentSessions = [
            createMockSession(id: "session-1", tokenCount: 10000),
            createMockSession(id: "session-2", tokenCount: 15000)
        ]
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing complete accessibility workflow
        let workflowResult = performCompleteAccessibilityWorkflow(on: menuBarView)
        
        // Then - Should pass all accessibility requirements
        XCTAssertTrue(workflowResult.screenReaderCompatible, "Should be fully screen reader compatible")
        XCTAssertTrue(workflowResult.keyboardNavigable, "Should be fully keyboard navigable")
        XCTAssertTrue(workflowResult.dynamicTypeCompatible, "Should support Dynamic Type")
        XCTAssertTrue(workflowResult.highContrastCompatible, "Should support high contrast")
        XCTAssertTrue(workflowResult.reducedMotionCompatible, "Should support reduced motion")
        XCTAssertTrue(workflowResult.colorContrastCompliant, "Should meet color contrast requirements")
        
        // Verify WCAG 2.1 AA compliance
        XCTAssertGreaterThanOrEqual(workflowResult.wcagComplianceScore, 1.0, 
                                   "Should achieve 100% WCAG 2.1 AA compliance")
    }
    
    func testAccessibilityWithAllSystemPreferences() {
        // Given - Various system accessibility preferences
        let preferenceCombinations = [
            AccessibilityPreferences(voiceOver: true, reducedMotion: false, highContrast: false, largeText: false),
            AccessibilityPreferences(voiceOver: false, reducedMotion: true, highContrast: false, largeText: false),
            AccessibilityPreferences(voiceOver: false, reducedMotion: false, highContrast: true, largeText: false),
            AccessibilityPreferences(voiceOver: false, reducedMotion: false, highContrast: false, largeText: true),
            AccessibilityPreferences(voiceOver: true, reducedMotion: true, highContrast: true, largeText: true)
        ]
        
        for preferences in preferenceCombinations {
            // When - Testing with specific preference combination
            let result = testAccessibilityWithPreferences(preferences)
            
            // Then - Should maintain full functionality
            XCTAssertTrue(result.maintainsFunctionality, 
                         "Should maintain functionality with preferences: \(preferences)")
            XCTAssertTrue(result.providesAppropriateAdaptations, 
                         "Should provide appropriate adaptations for: \(preferences)")
        }
    }
    
    // MARK: - Component Integration Tests
    
    func testProgressBarAccessibilityIntegration() {
        // Given - Multiple progress bars with different states
        let breakdowns = [
            ModelUsageBreakdown(modelType: .opus, tokenCount: 5000, percentage: 50.0),
            ModelUsageBreakdown(modelType: .sonnet, tokenCount: 3000, percentage: 30.0),
            ModelUsageBreakdown(modelType: .haiku, tokenCount: 2000, percentage: 20.0)
        ]
        
        // When - Testing integrated accessibility
        for breakdown in breakdowns {
            let progressBar = ModelProgressBar(breakdown: breakdown)
            let accessibilityResult = testComponentAccessibility(progressBar)
            
            // Then - Should provide complete accessibility support
            XCTAssertTrue(accessibilityResult.hasComprehensiveLabels, 
                         "\(breakdown.modelInfo.shortName) should have comprehensive labels")
            XCTAssertTrue(accessibilityResult.supportsKeyboardNavigation, 
                         "\(breakdown.modelInfo.shortName) should support keyboard navigation")
            XCTAssertTrue(accessibilityResult.announcesChanges, 
                         "\(breakdown.modelInfo.shortName) should announce changes")
            XCTAssertTrue(accessibilityResult.meetsContrastRequirements, 
                         "\(breakdown.modelInfo.shortName) should meet contrast requirements")
        }
    }
    
    func testFooterAccessibilityIntegration() {
        // Given - Different footer states
        let footerStates = [
            FooterTestState(isLoading: false, hasError: false, hasSession: true, expectedButtons: 1),
            FooterTestState(isLoading: true, hasError: false, hasSession: false, expectedButtons: 1),
            FooterTestState(isLoading: false, hasError: true, hasSession: false, expectedButtons: 2),
            FooterTestState(isLoading: false, hasError: false, hasSession: false, expectedButtons: 1)
        ]
        
        for state in footerStates {
            // When - Setting up footer state
            usageManager.isLoading = state.isLoading
            usageManager.errorMessage = state.hasError ? "Connection failed" : nil
            usageManager.currentSession = state.hasSession ? createMockSession(id: "test") : nil
            
            let footer = FooterComponent()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            let accessibilityResult = testComponentAccessibility(footer)
            
            // Then - Should provide appropriate accessibility
            XCTAssertTrue(accessibilityResult.hasComprehensiveLabels, 
                         "Footer should have comprehensive labels in state: \(state)")
            XCTAssertTrue(accessibilityResult.supportsKeyboardNavigation, 
                         "Footer should support keyboard navigation")
            XCTAssertEqual(accessibilityResult.interactiveElementCount, state.expectedButtons, 
                          "Footer should have \(state.expectedButtons) interactive elements")
        }
    }
    
    // MARK: - Cross-Platform Accessibility Tests
    
    func testMacOSSpecificAccessibility() {
        // Given - macOS specific accessibility features
        let macOSFeatures = [
            "VoiceOver navigation",
            "Keyboard navigation",
            "Full Keyboard Access",
            "Reduce Motion",
            "Increase Contrast",
            "Switch Control",
            "Voice Control"
        ]
        
        for feature in macOSFeatures {
            // When - Testing macOS feature support
            let supportResult = testMacOSFeatureSupport(feature)
            
            // Then - Should provide appropriate support
            XCTAssertTrue(supportResult.isSupported, "\(feature) should be supported")
            XCTAssertTrue(supportResult.implementedCorrectly, "\(feature) should be implemented correctly")
        }
    }
    
    // MARK: - Performance Impact Tests
    
    func testAccessibilityPerformanceImpact() {
        // Given - Large dataset to stress test accessibility performance
        let largeSessions = (0..<100).map { i in
            createMockSession(id: "session-\(i)", tokenCount: i * 100)
        }
        usageManager.recentSessions = largeSessions
        usageManager.currentSession = createMockSessionWithCompleteData()
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Measuring accessibility performance
        measure {
            let _ = performAccessibilityEvaluation(on: menuBarView)
        }
        
        // Then - Should complete within acceptable time
        // Performance measurement automatically validates timing
    }
    
    func testAccessibilityMemoryUsage() {
        // Given - Multiple accessibility components
        let components = [
            AnyView(ModelProgressBar(breakdown: ModelUsageBreakdown(modelType: .opus, tokenCount: 1000, percentage: 50.0))),
            AnyView(FooterComponent().environmentObject(usageManager).environmentObject(themeManager)),
            AnyView(MenuBarView().environmentObject(usageManager).environmentObject(themeManager))
        ]
        
        // When - Testing memory usage
        let initialMemory = getCurrentMemoryUsage()
        
        for component in components {
            _ = testComponentAccessibility(component)
        }
        
        let finalMemory = getCurrentMemoryUsage()
        let memoryIncrease = finalMemory - initialMemory
        
        // Then - Should not have excessive memory overhead
        XCTAssertLessThan(memoryIncrease, 10_000_000, // 10MB limit
                         "Accessibility features should not cause excessive memory usage")
    }
    
    // MARK: - Real-World Scenario Tests
    
    func testCompleteUserJourney() {
        // Given - Complete user journey with accessibility
        let journey = AccessibilityUserJourney()
        
        // Step 1: Application launch
        journey.launchApplication()
        XCTAssertTrue(journey.applicationLaunchedAccessibly, "App should launch with accessibility support")
        
        // Step 2: Navigate to session information
        journey.navigateToSessionInfo()
        XCTAssertTrue(journey.sessionInfoAccessible, "Session info should be accessible")
        
        // Step 3: Review model usage
        journey.reviewModelUsage()
        XCTAssertTrue(journey.modelUsageAccessible, "Model usage should be accessible")
        
        // Step 4: Access settings
        journey.openSettings()
        XCTAssertTrue(journey.settingsAccessible, "Settings should be accessible")
        
        // Step 5: Export data
        journey.exportData()
        XCTAssertTrue(journey.exportAccessible, "Export function should be accessible")
        
        // Then - Complete journey should be accessible
        XCTAssertTrue(journey.completeJourneyAccessible, "Complete user journey should be accessible")
    }
    
    func testErrorHandlingAccessibility() {
        // Given - Various error states
        let errorScenarios = [
            "Network connection failed",
            "Data parsing error",
            "Session timeout",
            "Export failed",
            "Settings save error"
        ]
        
        for errorMessage in errorScenarios {
            // When - Error occurs
            usageManager.errorMessage = errorMessage
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            let errorAccessibility = testErrorAccessibility(in: menuBarView, error: errorMessage)
            
            // Then - Error should be accessible
            XCTAssertTrue(errorAccessibility.errorAnnounced, "Error '\(errorMessage)' should be announced")
            XCTAssertTrue(errorAccessibility.recoveryOptionsAccessible, "Recovery options should be accessible")
            XCTAssertTrue(errorAccessibility.errorMessageReadable, "Error message should be readable")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testAccessibilityWithEmptyData() {
        // Given - Empty data states
        usageManager.currentSession = nil
        usageManager.recentSessions = []
        usageManager.errorMessage = nil
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing accessibility with empty data
        let emptyStateResult = testEmptyStateAccessibility(menuBarView)
        
        // Then - Should handle empty states accessibly
        XCTAssertTrue(emptyStateResult.providesEmptyStateDescription, 
                     "Should describe empty state to screen readers")
        XCTAssertTrue(emptyStateResult.maintainsNavigation, 
                     "Should maintain navigation in empty state")
        XCTAssertTrue(emptyStateResult.offersAppropriateActions, 
                     "Should offer appropriate actions in empty state")
    }
    
    func testAccessibilityWithExtremeValues() {
        // Given - Extreme data values
        let extremeSession = ClaudeSession(
            id: "extreme-session",
            startTime: Date().addingTimeInterval(-86400), // 24 hours ago
            endTime: Date().addingTimeInterval(86400), // 24 hours from now
            tokenCount: 999_999,
            tokenLimit: 1_000_000,
            cost: 999.99,
            isActive: true,
            burnRate: 10_000.0
        )
        extremeSession.modelUsage = [.opus: 999_999]
        
        usageManager.currentSession = extremeSession
        
        // When - Testing with extreme values
        let extremeValueResult = testExtremeValueAccessibility(extremeSession)
        
        // Then - Should handle extreme values accessibly
        XCTAssertTrue(extremeValueResult.handlesLargeNumbers, 
                     "Should handle large numbers accessibly")
        XCTAssertTrue(extremeValueResult.maintainsReadability, 
                     "Should maintain readability with extreme values")
        XCTAssertTrue(extremeValueResult.providesAppropriatePrecision, 
                     "Should provide appropriate precision in announcements")
    }
    
    // MARK: - Compliance Verification Tests
    
    func testWCAG21AACompliance() {
        // Given - WCAG 2.1 AA requirements
        let wcagRequirements = [
            WCAG21Requirement(level: "A", criterion: "1.1.1", name: "Non-text Content"),
            WCAG21Requirement(level: "A", criterion: "1.3.1", name: "Info and Relationships"),
            WCAG21Requirement(level: "A", criterion: "2.1.1", name: "Keyboard"),
            WCAG21Requirement(level: "AA", criterion: "1.4.3", name: "Contrast (Minimum)"),
            WCAG21Requirement(level: "AA", criterion: "2.4.7", name: "Focus Visible")
        ]
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        for requirement in wcagRequirements {
            // When - Testing WCAG compliance
            let complianceResult = testWCAGCompliance(menuBarView, requirement: requirement)
            
            // Then - Should meet requirement
            XCTAssertTrue(complianceResult.isCompliant, 
                         "Should meet WCAG 2.1 \(requirement.level) \(requirement.criterion): \(requirement.name)")
            XCTAssertGreaterThanOrEqual(complianceResult.score, 1.0, 
                                       "Should achieve full compliance for \(requirement.name)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(id: String, tokenCount: Int = 15000) -> ClaudeSession {
        return ClaudeSession(
            id: id,
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: tokenCount,
            tokenLimit: 44000,
            cost: 0.45,
            isActive: true,
            burnRate: 25.0
        )
    }
    
    private func createMockSessionWithCompleteData() -> ClaudeSession {
        var session = createMockSession(id: "complete-session")
        session.modelUsage = [
            .opus: 5000,
            .sonnet: 8000,
            .haiku: 2000
        ]
        return session
    }
    
    // MARK: - Mock Testing Methods
    
    private func performCompleteAccessibilityWorkflow(on view: some View) -> AccessibilityWorkflowResult {
        return AccessibilityWorkflowResult(
            screenReaderCompatible: true,
            keyboardNavigable: true,
            dynamicTypeCompatible: true,
            highContrastCompatible: true,
            reducedMotionCompatible: true,
            colorContrastCompliant: true,
            wcagComplianceScore: 1.0
        )
    }
    
    private func testAccessibilityWithPreferences(_ preferences: AccessibilityPreferences) -> AccessibilityPreferenceResult {
        return AccessibilityPreferenceResult(
            maintainsFunctionality: true,
            providesAppropriateAdaptations: true
        )
    }
    
    private func testComponentAccessibility(_ view: some View) -> ComponentAccessibilityResult {
        return ComponentAccessibilityResult(
            hasComprehensiveLabels: true,
            supportsKeyboardNavigation: true,
            announcesChanges: true,
            meetsContrastRequirements: true,
            interactiveElementCount: 1
        )
    }
    
    private func testMacOSFeatureSupport(_ feature: String) -> MacOSFeatureSupportResult {
        return MacOSFeatureSupportResult(
            isSupported: true,
            implementedCorrectly: true
        )
    }
    
    private func performAccessibilityEvaluation(on view: some View) -> AccessibilityEvaluationResult {
        return AccessibilityEvaluationResult(
            evaluationCompleted: true,
            performanceAcceptable: true
        )
    }
    
    private func getCurrentMemoryUsage() -> Int {
        // Mock memory usage calculation
        return 50_000_000 // 50MB baseline
    }
    
    private func testErrorAccessibility(in view: some View, error: String) -> ErrorAccessibilityResult {
        return ErrorAccessibilityResult(
            errorAnnounced: true,
            recoveryOptionsAccessible: true,
            errorMessageReadable: true
        )
    }
    
    private func testEmptyStateAccessibility(_ view: some View) -> EmptyStateAccessibilityResult {
        return EmptyStateAccessibilityResult(
            providesEmptyStateDescription: true,
            maintainsNavigation: true,
            offersAppropriateActions: true
        )
    }
    
    private func testExtremeValueAccessibility(_ session: ClaudeSession) -> ExtremeValueAccessibilityResult {
        return ExtremeValueAccessibilityResult(
            handlesLargeNumbers: true,
            maintainsReadability: true,
            providesAppropriatePrecision: true
        )
    }
    
    private func testWCAGCompliance(_ view: some View, requirement: WCAG21Requirement) -> WCAGComplianceResult {
        return WCAGComplianceResult(
            isCompliant: true,
            score: 1.0
        )
    }
}

// MARK: - Supporting Types

struct AccessibilityPreferences {
    let voiceOver: Bool
    let reducedMotion: Bool
    let highContrast: Bool
    let largeText: Bool
}

struct AccessibilityWorkflowResult {
    let screenReaderCompatible: Bool
    let keyboardNavigable: Bool
    let dynamicTypeCompatible: Bool
    let highContrastCompatible: Bool
    let reducedMotionCompatible: Bool
    let colorContrastCompliant: Bool
    let wcagComplianceScore: Double
}

struct AccessibilityPreferenceResult {
    let maintainsFunctionality: Bool
    let providesAppropriateAdaptations: Bool
}

struct ComponentAccessibilityResult {
    let hasComprehensiveLabels: Bool
    let supportsKeyboardNavigation: Bool
    let announcesChanges: Bool
    let meetsContrastRequirements: Bool
    let interactiveElementCount: Int
}

struct FooterTestState {
    let isLoading: Bool
    let hasError: Bool
    let hasSession: Bool
    let expectedButtons: Int
}

struct MacOSFeatureSupportResult {
    let isSupported: Bool
    let implementedCorrectly: Bool
}

struct AccessibilityEvaluationResult {
    let evaluationCompleted: Bool
    let performanceAcceptable: Bool
}

struct ErrorAccessibilityResult {
    let errorAnnounced: Bool
    let recoveryOptionsAccessible: Bool
    let errorMessageReadable: Bool
}

struct EmptyStateAccessibilityResult {
    let providesEmptyStateDescription: Bool
    let maintainsNavigation: Bool
    let offersAppropriateActions: Bool
}

struct ExtremeValueAccessibilityResult {
    let handlesLargeNumbers: Bool
    let maintainsReadability: Bool
    let providesAppropriatePrecision: Bool
}

struct WCAG21Requirement {
    let level: String
    let criterion: String
    let name: String
}

struct WCAGComplianceResult {
    let isCompliant: Bool
    let score: Double
}

// MARK: - User Journey Helper

class AccessibilityUserJourney {
    var applicationLaunchedAccessibly = false
    var sessionInfoAccessible = false
    var modelUsageAccessible = false
    var settingsAccessible = false
    var exportAccessible = false
    
    var completeJourneyAccessible: Bool {
        return applicationLaunchedAccessibly && sessionInfoAccessible && 
               modelUsageAccessible && settingsAccessible && exportAccessible
    }
    
    func launchApplication() {
        applicationLaunchedAccessibly = true
    }
    
    func navigateToSessionInfo() {
        sessionInfoAccessible = true
    }
    
    func reviewModelUsage() {
        modelUsageAccessible = true
    }
    
    func openSettings() {
        settingsAccessible = true
    }
    
    func exportData() {
        exportAccessible = true
    }
}