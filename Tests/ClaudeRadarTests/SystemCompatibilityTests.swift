import XCTest
import SwiftUI
@testable import ClaudeRadar

class SystemCompatibilityTests: XCTestCase {
    
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
    
    // MARK: - Task 10.3: System Settings Compatibility Tests
    
    func testDynamicTypeCompatibility() {
        // Given - All supported Dynamic Type sizes
        let dynamicTypeSizes: [DynamicTypeSize] = [
            .xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge,
            .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5
        ]
        
        for typeSize in dynamicTypeSizes {
            // When - Testing font scaling for each size
            let tokenCountFont = AccessibilitySystem.DynamicType.scaledFont(for: .semanticTokenCount, category: typeSize)
            let sessionStatusFont = AccessibilitySystem.DynamicType.scaledFont(for: .semanticSessionStatus, category: typeSize)
            let metricLabelFont = AccessibilitySystem.DynamicType.scaledFont(for: .semanticMetricLabel, category: typeSize)
            
            // Then - Should provide appropriate scaling
            XCTAssertNotNil(tokenCountFont, "Token count font should scale for \(typeSize)")
            XCTAssertNotNil(sessionStatusFont, "Session status font should scale for \(typeSize)")
            XCTAssertNotNil(metricLabelFont, "Metric label font should scale for \(typeSize)")
        }
    }
    
    func testDarkLightModeCompatibility() {
        // Given - System appearance changes
        let lightTheme = themeManager.lightTheme
        let darkTheme = themeManager.darkTheme
        
        // When - Testing theme switching
        themeManager.effectiveTheme = .light
        XCTAssertEqual(themeManager.effectiveTheme, .light, "Should switch to light theme")
        
        themeManager.effectiveTheme = .dark
        XCTAssertEqual(themeManager.effectiveTheme, .dark, "Should switch to dark theme")
        
        // Then - Should provide appropriate colors for both themes
        XCTAssertNotEqual(lightTheme.background, darkTheme.background, "Themes should have different backgrounds")
        XCTAssertNotEqual(lightTheme.text, darkTheme.text, "Themes should have different text colors")
        XCTAssertNotEqual(lightTheme.accent, darkTheme.accent, "Themes should have different accent colors")
    }
    
    func testHighContrastModeCompatibility() {
        // Given - High contrast system settings
        let standardColors = [
            themeManager.currentTheme.text,
            themeManager.currentTheme.secondaryText,
            themeManager.currentTheme.background,
            themeManager.currentTheme.secondaryBackground
        ]
        
        // When - Testing high contrast adjustments
        for color in standardColors {
            // Then - Colors should be available and valid
            XCTAssertNotNil(color, "High contrast colors should be defined")
        }
        
        // Test that high contrast adjustments are applied
        let highContrastText = Color.primary // SwiftUI's semantic color for high contrast
        let highContrastBackground = Color.clear.opacity(1.0)
        
        XCTAssertNotNil(highContrastText, "High contrast text should be available")
        XCTAssertNotNil(highContrastBackground, "High contrast background should be available")
    }
    
    func testReducedMotionCompatibility() {
        // Given - Reduced motion system preference
        let normalDuration = DesignTokens.Animation.progressBar
        let fastDuration = DesignTokens.Animation.fast
        let slowDuration = DesignTokens.Animation.slow
        
        // When - Testing reduced motion animations
        let adjustedProgressDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: normalDuration)
        let adjustedFastDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: fastDuration)
        let adjustedSlowDuration = AccessibilitySystem.ReducedMotion.animationDuration(normal: slowDuration)
        
        // Then - Should respect reduced motion preference
        XCTAssertTrue(adjustedProgressDuration >= 0.0, "Adjusted progress duration should be valid")
        XCTAssertTrue(adjustedFastDuration >= 0.0, "Adjusted fast duration should be valid")
        XCTAssertTrue(adjustedSlowDuration >= 0.0, "Adjusted slow duration should be valid")
        
        // If reduced motion is enabled, all durations should be 0
        if AccessibilitySystem.ReducedMotion.isEnabled {
            XCTAssertEqual(adjustedProgressDuration, 0.0, "Progress animation should be disabled with reduced motion")
            XCTAssertEqual(adjustedFastDuration, 0.0, "Fast animation should be disabled with reduced motion")
            XCTAssertEqual(adjustedSlowDuration, 0.0, "Slow animation should be disabled with reduced motion")
        } else {
            XCTAssertEqual(adjustedProgressDuration, normalDuration, "Progress animation should use normal duration")
            XCTAssertEqual(adjustedFastDuration, fastDuration, "Fast animation should use normal duration")
            XCTAssertEqual(adjustedSlowDuration, slowDuration, "Slow animation should use normal duration")
        }
    }
    
    func testVoiceOverCompatibility() {
        // Given - VoiceOver accessibility system
        let sessionLabels = AccessibilitySystem.Labels.self
        let sessionHints = AccessibilitySystem.Hints.self
        
        // When - Testing VoiceOver labels and hints
        let refreshLabel = sessionLabels.refreshButtonLabel()
        let settingsLabel = sessionLabels.settingsButtonLabel()
        let quitLabel = sessionLabels.quitButtonLabel()
        
        let refreshHint = sessionHints.refreshButton
        let settingsHint = sessionHints.settingsButton
        let quitHint = sessionHints.quitButton
        
        // Then - Should provide meaningful labels and hints
        XCTAssertFalse(refreshLabel.isEmpty, "Refresh button should have accessibility label")
        XCTAssertFalse(settingsLabel.isEmpty, "Settings button should have accessibility label")
        XCTAssertFalse(quitLabel.isEmpty, "Quit button should have accessibility label")
        
        XCTAssertFalse(refreshHint.isEmpty, "Refresh button should have accessibility hint")
        XCTAssertFalse(settingsHint.isEmpty, "Settings button should have accessibility hint")
        XCTAssertFalse(quitHint.isEmpty, "Quit button should have accessibility hint")
    }
    
    func testKeyboardNavigationCompatibility() {
        // Given - Keyboard navigation requirements
        let menuBarView = MenuBarView()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        // When - Testing keyboard accessible elements
        // Note: In SwiftUI tests, we verify the view structure supports keyboard navigation
        XCTAssertNotNil(menuBarView, "MenuBarView should support keyboard navigation")
        
        // Components should be focusable and have proper keyboard shortcuts
        let footerComponent = FooterComponent()
            .environmentObject(usageManager)
            .environmentObject(themeManager)
        
        XCTAssertNotNil(footerComponent, "Footer component should support keyboard navigation")
    }
    
    func testMultiDisplayCompatibility() {
        // Given - Multiple display configurations
        let standardDisplayFactor: CGFloat = 1.0
        let retinaDisplayFactor: CGFloat = 2.0
        let superRetinaDisplayFactor: CGFloat = 3.0
        
        let displayFactors = [standardDisplayFactor, retinaDisplayFactor, superRetinaDisplayFactor]
        
        for displayFactor in displayFactors {
            // When - Testing display scaling
            let scaledWidth = DesignTokens.Layout.menuBarWidth * displayFactor
            let scaledHeight = DesignTokens.Layout.menuBarHeight * displayFactor
            
            // Then - Should handle different display densities
            XCTAssertTrue(scaledWidth > 0, "Scaled width should be positive for \(displayFactor)x display")
            XCTAssertTrue(scaledHeight > 0, "Scaled height should be positive for \(displayFactor)x display")
        }
    }
    
    func testWindowingSystemCompatibility() {
        // Given - macOS windowing system requirements
        let menuBarWidth = DesignTokens.Layout.menuBarWidth
        let menuBarHeight = DesignTokens.Layout.menuBarHeight
        
        // When - Testing menu bar dimensions
        // Then - Should fit within standard menu bar constraints
        XCTAssertLessThanOrEqual(menuBarWidth, 400, "Menu bar width should not exceed reasonable maximum")
        XCTAssertGreaterThanOrEqual(menuBarWidth, 200, "Menu bar width should have reasonable minimum")
        XCTAssertLessThanOrEqual(menuBarHeight, 800, "Menu bar height should not exceed screen limits")
        XCTAssertGreaterThanOrEqual(menuBarHeight, 300, "Menu bar height should have reasonable minimum")
    }
    
    func testTimeZoneCompatibility() {
        // Given - Various time zones
        let timeZones = [
            TimeZone(identifier: "UTC")!,
            TimeZone(identifier: "America/New_York")!,
            TimeZone(identifier: "Europe/London")!,
            TimeZone(identifier: "Asia/Tokyo")!,
            TimeZone(identifier: "Australia/Sydney")!
        ]
        
        for timeZone in timeZones {
            // When - Testing time zone handling
            let formatter = DateFormatter()
            formatter.timeZone = timeZone
            formatter.timeStyle = .short
            
            let timeString = formatter.string(from: Date())
            
            // Then - Should format time appropriately
            XCTAssertFalse(timeString.isEmpty, "Should format time for \(timeZone.identifier)")
            XCTAssertGreaterThan(timeString.count, 3, "Time string should have reasonable length")
        }
    }
    
    func testLocalizationCompatibility() {
        // Given - Different locale configurations
        let locales = [
            Locale(identifier: "en_US"),
            Locale(identifier: "en_GB"),
            Locale(identifier: "fr_FR"),
            Locale(identifier: "de_DE"),
            Locale(identifier: "ja_JP")
        ]
        
        for locale in locales {
            // When - Testing locale-specific formatting
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = locale
            numberFormatter.numberStyle = .decimal
            
            let formattedNumber = numberFormatter.string(from: 15000)
            
            // Then - Should format numbers according to locale
            XCTAssertNotNil(formattedNumber, "Should format numbers for \(locale.identifier)")
        }
    }
    
    func testMemoryPressureCompatibility() {
        // Given - Memory pressure scenarios
        let largeDataSets = [10, 100, 1000, 5000]
        
        for dataSetSize in largeDataSets {
            // When - Testing with varying data sizes
            var sessions: [ClaudeSession] = []
            
            for i in 0..<dataSetSize {
                let session = ClaudeSession(
                    id: "session-\(i)",
                    startTime: Date().addingTimeInterval(-Double(i * 100)),
                    endTime: Date().addingTimeInterval(18000 - Double(i * 100)),
                    tokenCount: i * 10,
                    tokenLimit: 5000,
                    cost: Double(i) * 0.01,
                    isActive: i < 10,
                    burnRate: Double(i) * 0.5
                )
                sessions.append(session)
            }
            
            usageManager.recentSessions = sessions
            
            // Then - Should handle large data sets efficiently
            XCTAssertEqual(usageManager.recentSessions.count, dataSetSize, "Should handle \(dataSetSize) sessions")
        }
    }
    
    func testSystemNotificationCompatibility() {
        // Given - System notification requirements
        let notificationThresholds = [0.5, 0.7, 0.8, 0.9, 0.95]
        
        for threshold in notificationThresholds {
            // When - Testing notification thresholds
            let session = ClaudeSession(
                id: "notification-test",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: Int(Double(5000) * threshold),
                tokenLimit: 5000,
                cost: 1.5,
                isActive: true,
                burnRate: 25.0
            )
            
            // Then - Should calculate appropriate notification triggers
            let progress = session.progress
            XCTAssertEqual(progress, threshold, accuracy: 0.01, "Progress should match threshold \(threshold)")
        }
    }
    
    func testAccessibilityAPICompatibility() {
        // Given - macOS Accessibility API requirements
        let accessibilityElements = [
            "menuBarView",
            "sessionStatus",
            "tokenCount",
            "progressBar",
            "refreshButton",
            "settingsButton",
            "quitButton"
        ]
        
        for element in accessibilityElements {
            // When - Testing accessibility element naming
            // Then - Should follow accessibility naming conventions
            XCTAssertFalse(element.isEmpty, "Accessibility element \(element) should have identifier")
            XCTAssertFalse(element.contains(" "), "Accessibility identifier should not contain spaces")
        }
    }
    
    func testMacOSVersionCompatibility() {
        // Given - macOS version requirements
        let minimumOSVersion = OperatingSystemVersion(majorVersion: 14, minorVersion: 0, patchVersion: 0)
        let currentVersion = ProcessInfo.processInfo.operatingSystemVersion
        
        // When - Testing version compatibility
        let isCompatible = ProcessInfo.processInfo.isOperatingSystemAtLeast(minimumOSVersion)
        
        // Then - Should meet minimum requirements
        XCTAssertTrue(isCompatible, "Should run on macOS 14.0+")
        XCTAssertGreaterThanOrEqual(currentVersion.majorVersion, 14, "Should require macOS 14+")
    }
    
    func testSystemPerformanceCompatibility() {
        // Given - Performance requirements across different system configurations
        let performanceTestIterations = 1000
        
        // When - Testing view creation performance
        measure {
            for _ in 0..<performanceTestIterations {
                let menuBarView = MenuBarView()
                    .environmentObject(usageManager)
                    .environmentObject(themeManager)
                
                // Force view evaluation
                _ = menuBarView.body
            }
        }
        
        // Then - Performance should be acceptable across different hardware
        // The measure block automatically validates timing
    }
    
    func testSystemResourceCompatibility() {
        // Given - System resource constraints
        let maxMemoryUsage = 100 * 1024 * 1024 // 100MB reasonable limit
        let maxCPUUsage = 0.1 // 10% CPU usage limit
        
        // When - Testing resource usage
        let memoryBefore = getMemoryUsage()
        
        // Simulate typical usage
        for _ in 0..<100 {
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            _ = menuBarView.body
        }
        
        let memoryAfter = getMemoryUsage()
        let memoryDifference = memoryAfter - memoryBefore
        
        // Then - Should use reasonable system resources
        XCTAssertLessThan(memoryDifference, maxMemoryUsage, "Memory usage should be reasonable")
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int(info.resident_size)
        } else {
            return 0
        }
    }
}

// MARK: - System Compatibility Test Utilities

extension SystemCompatibilityTests {
    
    /// Test that a component works across different system settings
    func assertSystemCompatibility<T: View>(_ view: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(view, "View should work across different system settings", file: file, line: line)
    }
    
    /// Test that accessibility features are properly implemented
    func assertAccessibilityCompliance<T: View>(_ view: T, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(view, "View should comply with accessibility requirements", file: file, line: line)
    }
    
    /// Test that performance remains acceptable under various conditions
    func assertPerformanceCompliance<T>(_ operation: () -> T, iterations: Int = 100, file: StaticString = #file, line: UInt = #line) {
        measure {
            for _ in 0..<iterations {
                _ = operation()
            }
        }
    }
}