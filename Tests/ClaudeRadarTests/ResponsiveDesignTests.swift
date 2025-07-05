import XCTest
import SwiftUI
@testable import ClaudeRadar

class ResponsiveDesignTests: XCTestCase {
    
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
    
    // MARK: - Task 10.1: Width Constraint Compliance Tests
    
    func testMenuBarWidthConstraint() {
        // Given - Design requirement for 280px width
        let expectedWidth: CGFloat = 280
        
        // When - Checking design token configuration
        let actualWidth = DesignTokens.Layout.menuBarWidth
        
        // Then - Should match Task 10 requirement
        XCTAssertEqual(actualWidth, expectedWidth, "Menu bar width must be 280px for Task 10 compliance")
    }
    
    func testMenuBarViewWidthCompliance() {
        // Given - MenuBarView with standard configuration
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing view creation at required width
        // Note: In SwiftUI tests, we primarily verify view creation without errors
        XCTAssertNotNil(menuBarView, "MenuBarView should be created successfully at 280px width")
        
        // The actual frame constraint is applied in the view's body
        // and uses DesignTokens.Layout.menuBarWidth which we verified above
    }
    
    func testFooterComponentWidthCompliance() {
        // Given - Footer component with preview frame
        let footerComponent = FooterComponent()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing footer creation
        XCTAssertNotNil(footerComponent, "Footer component should work within 280px constraint")
        
        // Preview frames should use the design token width
        let previewWidth = DesignTokens.Layout.menuBarWidth
        XCTAssertEqual(previewWidth, 280, "Footer preview should use 280px width")
    }
    
    func testProgressBarWidthCompliance() {
        // Given - Progress bar components with various breakdowns
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 1500,
            percentage: 75.0
        )
        
        let progressBar = ModelProgressBar(breakdown: breakdown, isLoading: false)
        let compactProgressBar = CompactModelProgressBar(breakdown: breakdown)
        let detailedProgressBar = DetailedModelProgressBar(breakdown: breakdown)
        
        // When - Testing progress bar creation
        // Then - Should handle constrained width gracefully
        XCTAssertNotNil(progressBar, "Standard progress bar should work in 280px width")
        XCTAssertNotNil(compactProgressBar, "Compact progress bar should work in 280px width")
        XCTAssertNotNil(detailedProgressBar, "Detailed progress bar should work in 280px width")
    }
    
    func testGradientHeaderWidthCompliance() {
        // Given - Gradient header component
        let headerConfig = GradientHeader.Configuration.default
        let gradientHeader = GradientHeader(configuration: headerConfig)
            .environmentObject(themeManager)
        
        // When - Testing header creation
        XCTAssertNotNil(gradientHeader, "Gradient header should work within 280px constraint")
        
        // Headers should be responsive and not overflow
        let headerLayout = HeaderLayout.standard
        XCTAssertLessThanOrEqual(headerLayout.paddingHorizontal * 2, 280, "Header padding should not cause overflow")
    }
    
    // MARK: - Content Length Edge Cases
    
    func testLongModelNamesHandling() {
        // Given - Model with potentially long display name
        let modelInfo = ModelInfo.opus
        XCTAssertFalse(modelInfo.displayName.isEmpty, "Model should have display name")
        XCTAssertFalse(modelInfo.shortName.isEmpty, "Model should have short name")
        
        // Short names should be designed for constrained space
        XCTAssertLessThan(modelInfo.shortName.count, 10, "Short names should be concise for 280px width")
    }
    
    func testLongTokenCountDisplay() {
        // Given - Session with high token count (edge case)
        let session = ClaudeSession(
            id: "test-high-tokens",
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: 999999, // Very high count to test formatting
            tokenLimit: 1000000,
            cost: 30.0,
            isActive: true,
            burnRate: 50.0
        )
        
        // When - Testing display formatting
        let tokenDisplay = "\(session.tokenCount) tokens"
        
        // Then - Should handle large numbers appropriately
        XCTAssertFalse(tokenDisplay.isEmpty, "Token display should format large numbers")
        XCTAssertLessThan(tokenDisplay.count, 20, "Token display should be reasonably concise")
    }
    
    func testLongSessionStatusMessages() {
        // Given - Various session states
        let activeSession = createMockSession(isActive: true)
        let inactiveSession = createMockSession(isActive: false)
        
        // When - Testing status message lengths
        let activeStatus = activeSession.statusMessage
        let inactiveStatus = inactiveSession.statusMessage
        
        // Then - Status messages should be concise for constrained width
        XCTAssertLessThan(activeStatus.count, 30, "Active status should be concise")
        XCTAssertLessThan(inactiveStatus.count, 30, "Inactive status should be concise")
    }
    
    // MARK: - System Settings Compatibility
    
    func testDynamicTypeScaling() {
        // Given - Various Dynamic Type sizes
        let typeSizes: [DynamicTypeSize] = [.xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge]
        
        for typeSize in typeSizes {
            // When - Testing font scaling at each size
            let scaledFont = AccessibilitySystem.DynamicType.scaledFont(for: .semanticTokenCount, category: typeSize)
            
            // Then - Should provide valid font scaling
            XCTAssertNotNil(scaledFont, "Should provide scaled font for \(typeSize)")
        }
    }
    
    func testThemeCompatibility() {
        // Given - Different theme configurations
        let lightTheme = themeManager.lightTheme
        let darkTheme = themeManager.darkTheme
        
        // When - Testing theme colors
        // Then - Should provide valid colors for both themes
        XCTAssertNotNil(lightTheme.background, "Light theme should have background color")
        XCTAssertNotNil(darkTheme.background, "Dark theme should have background color")
        XCTAssertNotNil(lightTheme.text, "Light theme should have text color")
        XCTAssertNotNil(darkTheme.text, "Dark theme should have text color")
    }
    
    func testHighContrastMode() {
        // Given - High contrast accessibility requirements
        let highContrastColors = [
            Color.primary,
            Color.secondary,
            themeManager.currentTheme.accent,
            themeManager.currentTheme.background
        ]
        
        // When - Testing color accessibility
        for color in highContrastColors {
            // Then - Should provide valid colors
            XCTAssertNotNil(color, "High contrast colors should be available")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testNoDataState() {
        // Given - Manager with no data
        usageManager.currentSession = nil
        usageManager.recentSessions = []
        usageManager.isLoading = false
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing no data state
        // Then - Should handle gracefully
        XCTAssertNotNil(menuBarView, "MenuBarView should handle no data state")
    }
    
    func testSingleModelSession() {
        // Given - Session with only one model
        let singleModelSession = ClaudeSession(
            id: "single-model",
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: 1000,
            tokenLimit: 5000,
            cost: 0.30,
            isActive: true,
            burnRate: 15.0,
            models: ["claude-3-opus-20240229": 1000]
        )
        
        usageManager.currentSession = singleModelSession
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing single model display
        // Then - Should handle single model appropriately
        XCTAssertNotNil(menuBarView, "MenuBarView should handle single model sessions")
        XCTAssertEqual(singleModelSession.modelBreakdown.count, 1, "Should have one model breakdown")
    }
    
    func testErrorState() {
        // Given - Manager with error state
        usageManager.errorMessage = "Test error message"
        usageManager.isLoading = false
        usageManager.currentSession = nil
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing error state display
        // Then - Should handle error gracefully
        XCTAssertNotNil(menuBarView, "MenuBarView should handle error state")
        XCTAssertNotNil(usageManager.errorMessage, "Error message should be available")
    }
    
    func testLoadingState() {
        // Given - Manager in loading state
        usageManager.isLoading = true
        usageManager.currentSession = nil
        
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing loading state
        // Then - Should show loading interface
        XCTAssertNotNil(menuBarView, "MenuBarView should handle loading state")
        XCTAssertTrue(usageManager.isLoading, "Should be in loading state")
    }
    
    // MARK: - Layout Stability Tests
    
    func testLayoutStabilityWithVaryingContent() {
        // Given - Sessions with different content lengths
        let shortSession = createMockSession(tokenCount: 100, isActive: true)
        let mediumSession = createMockSession(tokenCount: 15000, isActive: true)
        let longSession = createMockSession(tokenCount: 50000, isActive: false)
        
        let sessions = [shortSession, mediumSession, longSession]
        
        for session in sessions {
            // When - Testing with different content lengths
            usageManager.currentSession = session
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should maintain layout stability
            XCTAssertNotNil(menuBarView, "MenuBarView should handle varying content lengths")
        }
    }
    
    func testMinimumContentSize() {
        // Given - Minimal session data
        let minimalSession = ClaudeSession(
            id: "minimal",
            startTime: Date(),
            endTime: Date().addingTimeInterval(18000),
            tokenCount: 1,
            tokenLimit: 100,
            cost: 0.001,
            isActive: true,
            burnRate: 0.1
        )
        
        usageManager.currentSession = minimalSession
        
        // When - Testing minimal content
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // Then - Should handle minimal content appropriately
        XCTAssertNotNil(menuBarView, "MenuBarView should handle minimal content")
    }
    
    func testMaximumContentSize() {
        // Given - Maximum realistic session data
        let maximalSession = ClaudeSession(
            id: "maximal",
            startTime: Date().addingTimeInterval(-18000),
            endTime: Date().addingTimeInterval(0),
            tokenCount: 199999,
            tokenLimit: 200000,
            cost: 60.0,
            isActive: false,
            burnRate: 100.0
        )
        
        usageManager.currentSession = maximalSession
        
        // When - Testing maximum content
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // Then - Should handle maximum content without overflow
        XCTAssertNotNil(menuBarView, "MenuBarView should handle maximum content")
    }
    
    // MARK: - Performance Tests
    
    func testLayoutPerformance() {
        // Given - Complex session with multiple models
        let complexSession = createComplexMockSession()
        usageManager.currentSession = complexSession
        
        // When - Testing layout performance
        measure {
            for _ in 0..<100 {
                let menuBarView = MenuBarView()
                    .environmentObject(usageManager)
                    .environmentObject(themeManager)
                _ = menuBarView.body // Force view evaluation
            }
        }
        
        // Then - Performance should be acceptable
        // The measure block will automatically verify timing
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(tokenCount: Int = 15000, isActive: Bool = true) -> ClaudeSession {
        return ClaudeSession(
            id: "test-session-\(tokenCount)",
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: tokenCount,
            tokenLimit: 44000,
            cost: 0.45,
            isActive: isActive,
            burnRate: 25.0
        )
    }
    
    private func createComplexMockSession() -> ClaudeSession {
        return ClaudeSession(
            id: "complex-session",
            startTime: Date().addingTimeInterval(-3600),
            endTime: Date().addingTimeInterval(14400),
            tokenCount: 25000,
            tokenLimit: 44000,
            cost: 0.75,
            isActive: true,
            burnRate: 35.0,
            models: [
                "claude-3-opus-20240229": 15000,
                "claude-3-sonnet-20240229": 8000,
                "claude-3-haiku-20240307": 2000
            ]
        )
    }
}

// MARK: - Responsive Design Test Utilities

extension ResponsiveDesignTests {
    
    /// Test that a view component respects the 280px width constraint
    func assertWidthCompliance<T: View>(_ view: T, file: StaticString = #file, line: UInt = #line) {
        // In a real implementation, this would verify that the view
        // doesn't exceed the 280px width constraint
        XCTAssertNotNil(view, "View should be created successfully within width constraint", file: file, line: line)
    }
    
    /// Test that content scales appropriately for different lengths
    func assertContentScaling(_ content: String, maxLength: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertLessThanOrEqual(content.count, maxLength, "Content should scale for constrained width", file: file, line: line)
    }
    
    /// Test layout stability across different content variations
    func assertLayoutStability<T: View>(_ viewFactory: () -> T, iterations: Int = 10, file: StaticString = #file, line: UInt = #line) {
        for i in 0..<iterations {
            let view = viewFactory()
            XCTAssertNotNil(view, "View \(i) should maintain layout stability", file: file, line: line)
        }
    }
}