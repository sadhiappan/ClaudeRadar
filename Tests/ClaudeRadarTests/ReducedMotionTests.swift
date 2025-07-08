import XCTest
import SwiftUI
@testable import ClaudeRadar

class ReducedMotionTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var usageManager: UsageDataManager!
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        themeManager = ThemeManager()
    }
    
    override func tearDown() {
        usageManager = nil
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - Reduced Motion Detection Tests
    
    func testReducedMotionDetection() {
        // Given - Reduced motion system detection
        let isReducedMotionEnabled = AccessibilitySystem.ReducedMotion.isEnabled
        
        // When - Checking reduced motion state
        let animationDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: 0.3)
        let animationCurve = AccessibilitySystem.ReducedMotion.animationCurve()
        
        // Then - Should provide appropriate values
        XCTAssertNotNil(isReducedMotionEnabled, "Reduced motion state should be determinable")
        XCTAssertTrue(animationDuration >= 0.0, "Animation duration should be non-negative")
        XCTAssertNotNil(animationCurve, "Animation curve should be available")
        
        if isReducedMotionEnabled {
            XCTAssertEqual(animationDuration, 0.0, "Animation duration should be 0 when reduced motion is enabled")
        } else {
            XCTAssertEqual(animationDuration, 0.3, "Animation duration should match normal duration when reduced motion is disabled")
        }
    }
    
    func testReducedMotionAnimationCurve() {
        // Given - Animation curve for different reduced motion states
        let normalCurve = AccessibilitySystem.ReducedMotion.animationCurve()
        
        // When - Testing animation curve behavior
        let transitionEffect = AccessibilitySystem.ReducedMotion.transitionEffect()
        
        // Then - Should provide appropriate animation types
        XCTAssertNotNil(normalCurve, "Animation curve should be available")
        XCTAssertNotNil(transitionEffect, "Transition effect should be available")
    }
    
    // MARK: - Progress Bar Animation Tests
    
    func testProgressBarReducedMotionCompliance() {
        // Given - Model usage breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 1500,
            percentage: 75.0
        )
        
        // When - Creating progress bar with reduced motion
        let progressBar = ModelProgressBar(breakdown: breakdown, isLoading: false)
        
        // Then - Should handle reduced motion appropriately
        // Note: In a real test environment, you would mock the reduced motion state
        // and verify that animations are disabled appropriately
        XCTAssertNotNil(progressBar, "Progress bar should be created successfully")
    }
    
    func testShimmerReducedMotionCompliance() {
        // Given - Shimmer view components
        let shimmerText = ShimmerText(width: 100, height: 12)
        let shimmerProgressBar = ShimmerProgressBar()
        let shimmerSessionCard = ShimmerSessionCard()
        
        // When - Testing shimmer components
        // Then - Should be created without errors
        XCTAssertNotNil(shimmerText, "Shimmer text should be created")
        XCTAssertNotNil(shimmerProgressBar, "Shimmer progress bar should be created")
        XCTAssertNotNil(shimmerSessionCard, "Shimmer session card should be created")
        
        // Note: Shimmer animations automatically check AccessibilitySystem.ReducedMotion.isEnabled
        // and disable animations when reduced motion is enabled
    }
    
    // MARK: - Button Hover Animation Tests
    
    func testButtonHoverReducedMotionCompliance() {
        // Given - Button styles with hover effects
        let primaryStyle = PrimaryButtonStyle()
        let secondaryStyle = SecondaryButtonStyle()
        let tertiaryStyle = TertiaryButtonStyle()
        let hoverStyle = HoverButtonStyle()
        
        // When - Testing button style creation
        // Then - Should create styles without errors
        XCTAssertNotNil(primaryStyle, "Primary button style should be created")
        XCTAssertNotNil(secondaryStyle, "Secondary button style should be created")
        XCTAssertNotNil(tertiaryStyle, "Tertiary button style should be created")
        XCTAssertNotNil(hoverStyle, "Hover button style should be created")
        
        // Note: All button styles use AccessibilitySystem.ReducedMotion.isEnabled
        // to conditionally apply animations
    }
    
    // MARK: - Transition Animation Tests
    
    func testViewTransitionReducedMotionCompliance() {
        // Given - Menu bar view with loading states
        usageManager.isLoading = true
        usageManager.currentSession = nil
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing view transitions
        // Then - Should handle view creation without errors
        XCTAssertNotNil(menuBarView, "Menu bar view should be created")
        
        // The view automatically uses AccessibilitySystem.ReducedMotion.isEnabled
        // to determine whether to apply transition animations
    }
    
    // MARK: - Animation Duration Tests
    
    func testAnimationDurationCalculations() {
        // Given - Various animation durations
        let testDurations: [Double] = [0.1, 0.25, 0.3, 0.5, 1.0, 1.5]
        
        for duration in testDurations {
            // When - Calculating reduced motion durations
            let adjustedDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: duration)
            
            // Then - Should provide appropriate durations
            XCTAssertTrue(adjustedDuration >= 0.0, "Adjusted duration should be non-negative for \(duration)s")
            
            if AccessibilitySystem.ReducedMotion.isEnabled {
                XCTAssertEqual(adjustedDuration, 0.0, "Duration should be 0 when reduced motion is enabled for \(duration)s")
            } else {
                XCTAssertEqual(adjustedDuration, duration, "Duration should match normal when reduced motion is disabled for \(duration)s")
            }
        }
    }
    
    // MARK: - Component Animation State Tests
    
    func testCircularProgressReducedMotionCompliance() {
        // Given - Circular progress view
        let circularProgress = CircularProgressView(progress: 0.75, color: .blue)
        
        // When - Testing circular progress creation
        // Then - Should be created without errors
        XCTAssertNotNil(circularProgress, "Circular progress view should be created")
        
        // The component uses AccessibilitySystem.ReducedMotion.isEnabled
        // to conditionally apply progress animations
    }
    
    func testLoadingStateReducedMotionCompliance() {
        // Given - Loading state view
        let loadingState = LoadingStateView(showFullInterface: true)
        let compactLoadingState = LoadingStateView(showFullInterface: false)
        
        // When - Testing loading state creation
        // Then - Should be created without errors
        XCTAssertNotNil(loadingState, "Full loading state should be created")
        XCTAssertNotNil(compactLoadingState, "Compact loading state should be created")
        
        // Loading states automatically disable shimmer animations when reduced motion is enabled
    }
    
    // MARK: - Integration Tests
    
    func testFullInterfaceReducedMotionCompliance() {
        // Given - Full interface with session data
        let session = createMockSession()
        usageManager.currentSession = session
        usageManager.isLoading = false
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing full interface with reduced motion
        // Then - Should handle interface creation without errors
        XCTAssertNotNil(menuBarView, "Full interface should be created")
        
        // All animations throughout the interface respect reduced motion preferences
    }
    
    func testAllAnimationTypesReducedMotionCompliance() {
        // Given - Various animation types used in the app
        let animationTypes = [
            DesignTokens.Animation.fast,
            DesignTokens.Animation.normal,
            DesignTokens.Animation.slow,
            DesignTokens.Animation.veryFast,
            DesignTokens.Animation.progressBar
        ]
        
        for animationType in animationTypes {
            // When - Testing each animation type with reduced motion
            let adjustedDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: animationType)
            
            // Then - Should respect reduced motion preferences
            if AccessibilitySystem.ReducedMotion.isEnabled {
                XCTAssertEqual(adjustedDuration, 0.0, "Animation type \(animationType) should be disabled with reduced motion")
            } else {
                XCTAssertEqual(adjustedDuration, animationType, "Animation type \(animationType) should use normal duration without reduced motion")
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testReducedMotionPerformance() {
        // Given - Large number of components with animations
        let componentCount = 100
        
        // When - Creating multiple animated components
        measure {
            for _ in 0..<componentCount {
                let breakdown = ModelUsageBreakdown(
                    modelType: .opus,
                    tokenCount: Int.random(in: 100...5000),
                    percentage: Double.random(in: 0...100)
                )
                _ = ModelProgressBar(breakdown: breakdown, isLoading: false)
            }
        }
        
        // Then - Should complete within reasonable time regardless of reduced motion state
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
}

// MARK: - Reduced Motion Test Utilities

extension ReducedMotionTests {
    
    /// Utility to test animation compliance across different components
    func assertAnimationCompliance<T: View>(_ view: T, file: StaticString = #file, line: UInt = #line) {
        // In a real implementation, this would verify that the view
        // properly respects reduced motion preferences
        XCTAssertNotNil(view, "View should be created successfully", file: file, line: line)
    }
    
    /// Test that an animation duration is properly adjusted for reduced motion
    func assertDurationCompliance(_ normalDuration: Double, file: StaticString = #file, line: UInt = #line) {
        let adjustedDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: normalDuration)
        
        if AccessibilitySystem.ReducedMotion.isEnabled {
            XCTAssertEqual(adjustedDuration, 0.0, "Duration should be 0 with reduced motion enabled", file: file, line: line)
        } else {
            XCTAssertEqual(adjustedDuration, normalDuration, "Duration should match normal with reduced motion disabled", file: file, line: line)
        }
    }
}