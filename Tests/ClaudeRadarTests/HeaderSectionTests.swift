import XCTest
import SwiftUI
@testable import ClaudeRadar

class HeaderSectionTests: XCTestCase {
    
    // MARK: - Gradient Header Tests
    
    func testGradientHeaderCreation() {
        // Given - Header configuration
        let headerConfig = GradientHeader.Configuration(
            title: "Claude Radar",
            subtitle: "Token Usage Monitor",
            showsLocation: true,
            showsRefreshButton: true
        )
        
        // When - Creating gradient header
        let header = GradientHeader(configuration: headerConfig)
        
        // Then - Should initialize correctly
        XCTAssertNotNil(header)
        XCTAssertEqual(header.configuration.title, "Claude Radar")
        XCTAssertEqual(header.configuration.subtitle, "Token Usage Monitor")
        XCTAssertTrue(header.configuration.showsLocation)
        XCTAssertTrue(header.configuration.showsRefreshButton)
    }
    
    func testHeaderGradientColors() {
        // Given - Theme manager
        let themeManager = ThemeManager()
        
        // When - Getting gradient colors
        let lightGradient = GradientHeader.gradientColors(for: .light)
        let darkGradient = GradientHeader.gradientColors(for: .dark)
        
        // Then - Should provide appropriate gradients
        XCTAssertEqual(lightGradient.count, 2)
        XCTAssertEqual(darkGradient.count, 2)
        XCTAssertNotEqual(lightGradient.first, darkGradient.first)
    }
    
    func testHeaderStatusDisplay() {
        // Given - Active session
        let session = createMockSession(isActive: true, tokenCount: 2500, tokenLimit: 10000)
        
        // When - Creating header status
        let headerStatus = HeaderStatus(session: session)
        
        // Then - Should display correct status
        XCTAssertNotNil(headerStatus)
        XCTAssertEqual(headerStatus.statusText, "Active Session")
        XCTAssertEqual(headerStatus.progressPercentage, 25.0, accuracy: 0.1)
        XCTAssertNotNil(headerStatus.statusColor)
    }
    
    func testHeaderLocationDisplay() {
        // Given - Time zone and session
        let timeZone = TimeZone(identifier: "America/New_York")!
        let session = createMockSession(isActive: true, tokenCount: 1000, tokenLimit: 5000)
        
        // When - Creating location display
        let locationDisplay = HeaderLocationDisplay(timeZone: timeZone, session: session)
        
        // Then - Should show timezone and session info
        XCTAssertNotNil(locationDisplay)
        XCTAssertTrue(locationDisplay.timeZoneDisplay.contains("Eastern"))
        XCTAssertNotNil(locationDisplay.sessionEndTime)
    }
    
    // MARK: - Header Layout Tests
    
    func testHeaderDimensions() {
        // Given - Header layout
        let headerLayout = HeaderLayout.standard
        
        // Then - Should define appropriate dimensions
        XCTAssertEqual(headerLayout.height, 80)
        XCTAssertEqual(headerLayout.paddingHorizontal, DesignTokens.Spacing.lg)
        XCTAssertEqual(headerLayout.paddingVertical, DesignTokens.Spacing.md)
        XCTAssertEqual(headerLayout.cornerRadius, DesignTokens.BorderRadius.lg)
    }
    
    func testCompactHeaderLayout() {
        // Given - Compact header layout
        let compactLayout = HeaderLayout.compact
        
        // Then - Should have reduced dimensions
        XCTAssertEqual(compactLayout.height, 60)
        XCTAssertLessThan(compactLayout.height, HeaderLayout.standard.height)
        XCTAssertEqual(compactLayout.paddingHorizontal, DesignTokens.Spacing.md)
    }
    
    // MARK: - Header Content Tests
    
    func testHeaderTitleStyling() {
        // Given - Header title configuration
        let titleConfig = HeaderTitle.Configuration(
            text: "Claude Radar",
            style: .primary,
            showsIcon: true
        )
        
        // When - Creating header title
        let headerTitle = HeaderTitle(configuration: titleConfig)
        
        // Then - Should apply correct styling
        XCTAssertNotNil(headerTitle)
        XCTAssertEqual(headerTitle.configuration.text, "Claude Radar")
        XCTAssertEqual(headerTitle.configuration.style, .primary)
        XCTAssertTrue(headerTitle.configuration.showsIcon)
    }
    
    func testHeaderSubtitleStyling() {
        // Given - Header subtitle configuration
        let subtitleConfig = HeaderSubtitle.Configuration(
            text: "Token Usage Monitor",
            style: .secondary
        )
        
        // When - Creating header subtitle
        let headerSubtitle = HeaderSubtitle(configuration: subtitleConfig)
        
        // Then - Should apply correct styling
        XCTAssertNotNil(headerSubtitle)
        XCTAssertEqual(headerSubtitle.configuration.text, "Token Usage Monitor")
        XCTAssertEqual(headerSubtitle.configuration.style, .secondary)
    }
    
    // MARK: - Header Actions Tests
    
    func testHeaderRefreshButton() {
        // Given - Refresh button configuration
        let refreshConfig = HeaderRefreshButton.Configuration(
            isLoading: false,
            isEnabled: true
        )
        
        // When - Creating refresh button
        let refreshButton = HeaderRefreshButton(
            configuration: refreshConfig,
            action: {}
        )
        
        // Then - Should initialize correctly
        XCTAssertNotNil(refreshButton)
        XCTAssertFalse(refreshButton.configuration.isLoading)
        XCTAssertTrue(refreshButton.configuration.isEnabled)
    }
    
    func testHeaderRefreshButtonLoading() {
        // Given - Loading refresh button
        let loadingConfig = HeaderRefreshButton.Configuration(
            isLoading: true,
            isEnabled: false
        )
        
        // When - Creating loading refresh button
        let loadingButton = HeaderRefreshButton(
            configuration: loadingConfig,
            action: {}
        )
        
        // Then - Should show loading state
        XCTAssertTrue(loadingButton.configuration.isLoading)
        XCTAssertFalse(loadingButton.configuration.isEnabled)
    }
    
    // MARK: - Header Gradient System Tests
    
    func testHeaderGradientDirection() {
        // Given - Gradient configuration
        let gradientConfig = HeaderGradient.Configuration(
            colors: [.blue, .purple],
            direction: .topLeading,
            opacity: 0.8
        )
        
        // When - Creating gradient
        let gradient = HeaderGradient(configuration: gradientConfig)
        
        // Then - Should configure correctly
        XCTAssertNotNil(gradient)
        XCTAssertEqual(gradient.configuration.colors.count, 2)
        XCTAssertEqual(gradient.configuration.direction, .topLeading)
        XCTAssertEqual(gradient.configuration.opacity, 0.8, accuracy: 0.01)
    }
    
    func testThemeAwareGradients() {
        // Given - Different theme types
        let lightTheme = ThemeType.light
        let darkTheme = ThemeType.dark
        
        // When - Getting theme-aware gradients
        let lightGradient = HeaderGradient.themeAware(for: lightTheme)
        let darkGradient = HeaderGradient.themeAware(for: darkTheme)
        
        // Then - Should provide different gradients
        XCTAssertNotNil(lightGradient)
        XCTAssertNotNil(darkGradient)
        XCTAssertNotEqual(lightGradient.configuration.colors.count, 0)
        XCTAssertNotEqual(darkGradient.configuration.colors.count, 0)
    }
    
    // MARK: - Header Animation Tests
    
    func testHeaderAnimations() {
        // Given - Header animation configuration
        let animationConfig = HeaderAnimation.Configuration(
            entrance: .slideFromTop,
            duration: DesignTokens.Animation.normal,
            delay: 0.1
        )
        
        // When - Creating animation
        let animation = HeaderAnimation(configuration: animationConfig)
        
        // Then - Should configure animation
        XCTAssertNotNil(animation)
        XCTAssertEqual(animation.configuration.entrance, .slideFromTop)
        XCTAssertEqual(animation.configuration.duration, DesignTokens.Animation.normal)
        XCTAssertEqual(animation.configuration.delay, 0.1, accuracy: 0.01)
    }
    
    // MARK: - Header Accessibility Tests
    
    func testHeaderAccessibility() {
        // Given - Header with session data
        let session = createMockSession(isActive: true, tokenCount: 3000, tokenLimit: 10000)
        let headerConfig = GradientHeader.Configuration(
            title: "Claude Radar",
            subtitle: "Token Usage Monitor",
            showsLocation: true,
            showsRefreshButton: true
        )
        
        // When - Creating accessible header
        let accessibleHeader = AccessibleGradientHeader(
            configuration: headerConfig,
            session: session
        )
        
        // Then - Should provide accessibility support
        XCTAssertNotNil(accessibleHeader.accessibilityLabel)
        XCTAssertTrue(accessibleHeader.accessibilityLabel.contains("Claude Radar"))
        XCTAssertNotNil(accessibleHeader.accessibilityValue)
        XCTAssertTrue(accessibleHeader.accessibilityValue.contains("30%"))
    }
    
    // MARK: - Integration Tests
    
    func testCompleteHeaderIntegration() {
        // Given - Complete header with all components
        let session = createMockSession(isActive: true, tokenCount: 1500, tokenLimit: 5000)
        let themeManager = ThemeManager()
        
        // When - Creating complete header
        let completeHeader = CompleteGradientHeader(
            session: session,
            themeManager: themeManager,
            onRefresh: {}
        )
        
        // Then - Should integrate all components
        XCTAssertNotNil(completeHeader)
        XCTAssertNotNil(completeHeader.session)
        XCTAssertNotNil(completeHeader.themeManager)
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(isActive: Bool, tokenCount: Int, tokenLimit: Int) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: Date(),
            endTime: Date().addingTimeInterval(5 * 60 * 60),
            tokenCount: tokenCount,
            tokenLimit: tokenLimit,
            cost: 0.0,
            isActive: isActive,
            burnRate: 10.0
        )
    }
}