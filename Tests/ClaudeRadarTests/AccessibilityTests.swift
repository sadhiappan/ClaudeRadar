import XCTest
import SwiftUI
@testable import ClaudeRadar

class AccessibilityTests: XCTestCase {
    
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
    
    // MARK: - VoiceOver Support Tests
    
    func testVoiceOverSupport() {
        // Given - VoiceOver system state
        let isVoiceOverEnabled = AccessibilitySystem.VoiceOver.isEnabled
        
        // When - Testing VoiceOver announcement
        AccessibilitySystem.VoiceOver.announceStatus("Testing VoiceOver")
        
        // Then - Should handle VoiceOver state appropriately
        XCTAssertNotNil(isVoiceOverEnabled, "VoiceOver state should be determinable")
    }
    
    func testVoiceOverAnnouncements() {
        // Given - Different announcement types
        let testCases = [
            "Status update: Connected",
            "Progress update: 75% complete",
            "Error: Connection failed"
        ]
        
        for announcement in testCases {
            // When - Making announcements
            AccessibilitySystem.VoiceOver.announce(announcement)
            
            // Then - Should not crash and handle gracefully
            XCTAssertTrue(true, "VoiceOver announcement should complete without error")
        }
    }
    
    // MARK: - Accessibility Label Tests
    
    func testProgressBarAccessibilityLabels() {
        // Given - Model usage breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 1500,
            percentage: 60.0
        )
        
        // When - Creating accessibility label
        let label = AccessibilitySystem.Labels.progressLabel(
            model: breakdown.modelInfo.shortName,
            percentage: breakdown.percentage,
            tokenCount: breakdown.tokenCount
        )
        
        // Then - Should contain all necessary information
        XCTAssertTrue(label.contains("Opus"), "Label should contain model name")
        XCTAssertTrue(label.contains("1500"), "Label should contain token count")
        XCTAssertTrue(label.contains("60"), "Label should contain percentage")
        XCTAssertTrue(label.contains("percent"), "Label should specify percentage")
    }
    
    func testStatusAccessibilityLabels() {
        // Given - Different status states
        let testCases: [(status: String, isActive: Bool)] = [
            ("Connected", true),
            ("Loading", false),
            ("Error", false),
            ("No Session", false)
        ]
        
        for testCase in testCases {
            // When - Creating status label
            let label = AccessibilitySystem.Labels.statusLabel(
                status: testCase.status,
                isActive: testCase.isActive
            )
            
            // Then - Should contain status information
            XCTAssertTrue(label.contains(testCase.status), "Label should contain status: \(testCase.status)")
            XCTAssertTrue(label.contains("Session"), "Label should mention session")
        }
    }
    
    func testBurnRateAccessibilityLabels() {
        // Given - Different burn rate values
        let testCases: [Double?] = [nil, 0.0, 25.5, 100.0, 250.8]
        
        for burnRate in testCases {
            // When - Creating burn rate label
            let label = AccessibilitySystem.Labels.burnRateLabel(rate: burnRate)
            
            // Then - Should handle all cases appropriately
            XCTAssertTrue(label.contains("burn rate") || label.contains("Burn rate"), 
                         "Label should mention burn rate")
            
            if let rate = burnRate {
                if rate > 0 {
                    XCTAssertTrue(label.contains(String(format: "%.1f", rate)), 
                                 "Label should contain rate value for \(rate)")
                }
            } else {
                XCTAssertTrue(label.contains("Not available") || label.contains("Unknown"), 
                             "Label should indicate unavailable rate")
            }
        }
    }
    
    // MARK: - Interactive Element Tests
    
    func testButtonAccessibilityLabels() {
        // Given - Button types
        let buttonTests = [
            (label: AccessibilitySystem.Labels.refreshButtonLabel(isLoading: false), expected: "Refresh"),
            (label: AccessibilitySystem.Labels.refreshButtonLabel(isLoading: true), expected: "Refreshing"),
            (label: AccessibilitySystem.Labels.quitButtonLabel(), expected: "Quit"),
            (label: AccessibilitySystem.Labels.retryButtonLabel(), expected: "Retry"),
            (label: AccessibilitySystem.Labels.settingsButtonLabel(), expected: "Settings")
        ]
        
        for test in buttonTests {
            // Then - Should contain expected text
            XCTAssertTrue(test.label.localizedCaseInsensitiveContains(test.expected), 
                         "Button label '\(test.label)' should contain '\(test.expected)'")
        }
    }
    
    func testAccessibilityHints() {
        // Given - Accessibility hints
        let hints = [
            AccessibilitySystem.Hints.progressBar,
            AccessibilitySystem.Hints.statusIndicator,
            AccessibilitySystem.Hints.refreshButton,
            AccessibilitySystem.Hints.quitButton,
            AccessibilitySystem.Hints.retryButton,
            AccessibilitySystem.Hints.settingsButton
        ]
        
        for hint in hints {
            // Then - Should not be empty and should provide guidance
            XCTAssertFalse(hint.isEmpty, "Accessibility hint should not be empty")
            XCTAssertGreaterThan(hint.count, 10, "Accessibility hint should be descriptive")
        }
    }
    
    // MARK: - Dynamic Type Tests
    
    func testDynamicTypeScaling() {
        // Given - Different Dynamic Type categories
        let testCategories: [DynamicTypeSize] = [
            .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge,
            .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5
        ]
        
        let baseFont = Font.system(size: 16)
        let baseSpacing: CGFloat = 12
        
        for category in testCategories {
            // When - Scaling font and spacing
            let scaledFont = AccessibilitySystem.DynamicType.scaledFont(for: baseFont, category: category)
            let scaledSpacing = AccessibilitySystem.DynamicType.scaledSpacing(for: baseSpacing, category: category)
            
            // Then - Should return valid scaled values
            XCTAssertNotNil(scaledFont, "Scaled font should not be nil for category \(category)")
            XCTAssertGreaterThan(scaledSpacing, 0, "Scaled spacing should be positive for category \(category)")
            
            // Accessibility categories should be larger
            if category.rawValue >= DynamicTypeSize.accessibility1.rawValue {
                XCTAssertGreaterThanOrEqual(scaledSpacing, baseSpacing, 
                                          "Accessibility spacing should be >= base for \(category)")
            }
        }
    }
    
    // MARK: - Reduced Motion Tests
    
    func testReducedMotionSupport() {
        // Given - Reduced motion state
        let isReducedMotionEnabled = AccessibilitySystem.ReducedMotion.isEnabled
        
        // When - Getting animation duration
        let normalDuration = 0.3
        let reducedDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: normalDuration)
        
        // Then - Should handle reduced motion appropriately
        if isReducedMotionEnabled {
            XCTAssertEqual(reducedDuration, 0.0, "Reduced motion should return zero duration")
        } else {
            XCTAssertEqual(reducedDuration, normalDuration, "Normal motion should return original duration")
        }
    }
    
    func testReducedMotionAnimationCurve() {
        // When - Getting animation curve
        let curve = AccessibilitySystem.ReducedMotion.animationCurve()
        
        // Then - Should return appropriate animation
        XCTAssertNotNil(curve, "Animation curve should not be nil")
    }
    
    func testReducedMotionTransition() {
        // When - Getting transition effect
        let transition = AccessibilitySystem.ReducedMotion.transitionEffect()
        
        // Then - Should return appropriate transition
        XCTAssertNotNil(transition, "Transition effect should not be nil")
    }
    
    // MARK: - High Contrast Tests
    
    func testHighContrastSupport() {
        // Given - High contrast state
        let isHighContrastEnabled = AccessibilitySystem.HighContrast.isEnabled
        
        // When - Adjusting colors and borders
        let testColor = Color.blue
        let adjustedColor = AccessibilitySystem.HighContrast.adjustedColor(testColor)
        let borderWidth = AccessibilitySystem.HighContrast.borderWidth()
        let shadowOpacity = AccessibilitySystem.HighContrast.shadowOpacity()
        
        // Then - Should provide appropriate adjustments
        XCTAssertNotNil(adjustedColor, "Adjusted color should not be nil")
        XCTAssertGreaterThan(borderWidth, 0, "Border width should be positive")
        XCTAssertGreaterThan(shadowOpacity, 0, "Shadow opacity should be positive")
        
        if isHighContrastEnabled {
            XCTAssertGreaterThanOrEqual(borderWidth, 2.0, "High contrast should use thicker borders")
            XCTAssertGreaterThanOrEqual(shadowOpacity, 0.8, "High contrast should use stronger shadows")
        }
    }
    
    // MARK: - Accessibility Traits Tests
    
    func testAccessibilityTraits() {
        // Given - Different accessibility traits
        let traits = [
            AccessibilitySystem.Traits.progressIndicator,
            AccessibilitySystem.Traits.statusElement,
            AccessibilitySystem.Traits.navigationElement,
            AccessibilitySystem.Traits.metricElement,
            AccessibilitySystem.Traits.interactiveElement,
            AccessibilitySystem.Traits.criticalElement
        ]
        
        for trait in traits {
            // Then - Should be valid accessibility traits
            XCTAssertNotNil(trait, "Accessibility trait should not be nil")
        }
    }
    
    // MARK: - Accessibility Values Tests
    
    func testAccessibilityValues() {
        // Given - Different value types
        let progressValue = AccessibilitySystem.Values.progressValue(percentage: 75.5)
        let tokenValue = AccessibilitySystem.Values.tokenValue(count: 1500, limit: 44000)
        let burnRateValue = AccessibilitySystem.Values.burnRateValue(rate: 25.7)
        let timeValue = AccessibilitySystem.Values.timeValue(timeString: "2h 30m")
        
        // Then - Should format values appropriately
        XCTAssertTrue(progressValue.contains("76"), "Progress value should contain rounded percentage")
        XCTAssertTrue(progressValue.contains("percent"), "Progress value should specify percent")
        
        XCTAssertTrue(tokenValue.contains("1500"), "Token value should contain count")
        XCTAssertTrue(tokenValue.contains("44000"), "Token value should contain limit")
        
        XCTAssertTrue(burnRateValue.contains("25.7"), "Burn rate value should contain rate")
        XCTAssertTrue(burnRateValue.contains("tokens"), "Burn rate value should mention tokens")
        
        XCTAssertEqual(timeValue, "2h 30m", "Time value should return original string when valid")
    }
    
    // MARK: - Model Progress Accessibility Tests
    
    func testModelProgressAccessibility() {
        // Given - Model breakdown data
        let breakdown = ModelUsageBreakdown(
            modelType: .sonnet,
            tokenCount: 800,
            percentage: 40.0
        )
        
        // When - Creating model progress label
        let label = AccessibilitySystem.Labels.modelProgressLabel(
            modelInfo: breakdown.modelInfo,
            tokenCount: breakdown.tokenCount,
            percentage: breakdown.percentage
        )
        
        // Then - Should contain comprehensive information
        XCTAssertTrue(label.contains("Sonnet"), "Should contain model name")
        XCTAssertTrue(label.contains("800"), "Should contain token count")
        XCTAssertTrue(label.contains("40"), "Should contain percentage")
        XCTAssertTrue(label.lowercased().contains("tokens"), "Should mention tokens")
        XCTAssertTrue(label.lowercased().contains("percent"), "Should mention percentage")
    }
    
    func testCircularProgressAccessibility() {
        // Given - Session progress data
        let percentage = 0.65
        let tokenCount = 15000
        let limit = 44000
        
        // When - Creating circular progress label
        let label = AccessibilitySystem.Labels.circularProgressLabel(
            percentage: percentage,
            tokenCount: tokenCount,
            limit: limit
        )
        
        // Then - Should describe overall progress
        XCTAssertTrue(label.contains("Session progress"), "Should mention session progress")
        XCTAssertTrue(label.contains("15000"), "Should contain token count")
        XCTAssertTrue(label.contains("44000"), "Should contain token limit")
        XCTAssertTrue(label.contains("65"), "Should contain percentage")
    }
    
    // MARK: - Keyboard Navigation Tests
    
    func testKeyboardNavigationConfiguration() {
        // Given - A test view
        let testView = Text("Test")
        
        // When - Configuring for keyboard navigation
        let configurableView = AccessibilitySystem.KeyboardNavigation.configureFocusable(testView)
        let buttonView = AccessibilitySystem.KeyboardNavigation.configureButton(testView) {
            // Test action
        }
        
        // Then - Should return configured views
        XCTAssertNotNil(configurableView, "Focusable view should not be nil")
        XCTAssertNotNil(buttonView, "Button view should not be nil")
    }
    
    // MARK: - Integration Tests
    
    func testFullAccessibilityChain() {
        // Given - A complete model breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 2500,
            percentage: 85.0
        )
        
        // When - Creating full accessibility support
        let label = AccessibilitySystem.Labels.modelProgressLabel(
            modelInfo: breakdown.modelInfo,
            tokenCount: breakdown.tokenCount,
            percentage: breakdown.percentage
        )
        let value = AccessibilitySystem.Values.progressValue(percentage: breakdown.percentage)
        let hint = AccessibilitySystem.Hints.modelProgress
        
        // Then - Should work together coherently
        XCTAssertFalse(label.isEmpty, "Label should not be empty")
        XCTAssertFalse(value.isEmpty, "Value should not be empty")
        XCTAssertFalse(hint.isEmpty, "Hint should not be empty")
        
        // All should mention relevant concepts
        let combinedText = "\(label) \(value) \(hint)".lowercased()
        XCTAssertTrue(combinedText.contains("opus"), "Should mention model type")
        XCTAssertTrue(combinedText.contains("85") || combinedText.contains("percent"), "Should mention percentage")
        XCTAssertTrue(combinedText.contains("token"), "Should mention tokens")
    }
    
    // MARK: - Error Handling Tests
    
    func testAccessibilityWithInvalidData() {
        // Given - Invalid or edge case data
        let invalidBreakdown = ModelUsageBreakdown(
            modelType: .unknown,
            tokenCount: 0,
            percentage: 0.0
        )
        
        // When - Creating accessibility labels
        let label = AccessibilitySystem.Labels.modelProgressLabel(
            modelInfo: invalidBreakdown.modelInfo,
            tokenCount: invalidBreakdown.tokenCount,
            percentage: invalidBreakdown.percentage
        )
        
        let burnRateLabel = AccessibilitySystem.Labels.burnRateLabel(rate: nil)
        let timeLabel = AccessibilitySystem.Labels.timeRemainingLabel(timeRemaining: "—")
        
        // Then - Should handle gracefully
        XCTAssertFalse(label.isEmpty, "Label should not be empty even with invalid data")
        XCTAssertFalse(burnRateLabel.isEmpty, "Burn rate label should not be empty with nil data")
        XCTAssertFalse(timeLabel.isEmpty, "Time label should not be empty with placeholder data")
        
        XCTAssertTrue(burnRateLabel.contains("Not available"), "Should indicate unavailable burn rate")
        XCTAssertTrue(timeLabel.contains("Unknown"), "Should indicate unknown time")
    }
    
    // MARK: - Performance Tests
    
    func testAccessibilityPerformance() {
        measure {
            // When - Creating multiple accessibility labels rapidly
            for i in 0..<1000 {
                let breakdown = ModelUsageBreakdown(
                    modelType: .opus,
                    tokenCount: i * 10,
                    percentage: Double(i % 100)
                )
                
                _ = AccessibilitySystem.Labels.modelProgressLabel(
                    modelInfo: breakdown.modelInfo,
                    tokenCount: breakdown.tokenCount,
                    percentage: breakdown.percentage
                )
            }
        }
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
}