import XCTest
import SwiftUI
@testable import ClaudeRadar

class ColorContrastTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        themeManager = ThemeManager()
    }
    
    override func tearDown() {
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - WCAG 2.1 AA Contrast Tests
    
    func testTextColorContrast() {
        // Given - Text colors from design system
        let textColorTests = [
            (foreground: Color.primary, background: Color(NSColor.controlBackgroundColor), context: "Primary text"),
            (foreground: Color.secondary, background: Color(NSColor.controlBackgroundColor), context: "Secondary text"),
            (foreground: Color.accentBlue, background: Color.backgroundPrimary, context: "Accent blue text"),
            (foreground: Color.accentOrange, background: Color.backgroundPrimary, context: "Accent orange text"),
            (foreground: Color.accentGreen, background: Color.backgroundPrimary, context: "Accent green text")
        ]
        
        for test in textColorTests {
            // When - Calculating contrast ratio
            let contrastRatio = calculateContrastRatio(
                foreground: test.foreground,
                background: test.background
            )
            
            // Then - Should meet WCAG 2.1 AA requirements (4.5:1 for normal text)
            XCTAssertGreaterThanOrEqual(contrastRatio, 4.5, 
                                       "\(test.context) should meet WCAG 2.1 AA contrast requirement (4.5:1), got \(contrastRatio):1")
        }
    }
    
    func testLargeTextColorContrast() {
        // Given - Large text colors (18pt+ or 14pt+ bold)
        let largeTextTests = [
            (foreground: Color.statusSuccess, background: Color.backgroundPrimary, context: "Status success"),
            (foreground: Color.statusWarning, background: Color.backgroundPrimary, context: "Status warning"),
            (foreground: Color.statusCritical, background: Color.backgroundPrimary, context: "Status critical"),
            (foreground: Color.statusInfo, background: Color.backgroundPrimary, context: "Status info")
        ]
        
        for test in largeTextTests {
            // When - Calculating contrast ratio
            let contrastRatio = calculateContrastRatio(
                foreground: test.foreground,
                background: test.background
            )
            
            // Then - Should meet WCAG 2.1 AA requirements for large text (3:1)
            XCTAssertGreaterThanOrEqual(contrastRatio, 3.0, 
                                       "\(test.context) large text should meet WCAG 2.1 AA contrast requirement (3:1), got \(contrastRatio):1")
        }
    }
    
    func testModelColorContrast() {
        // Given - Model colors
        let modelColorTests = [
            (color: ModelInfo.opus.color, context: "Opus model color"),
            (color: ModelInfo.sonnet.color, context: "Sonnet model color"),
            (color: ModelInfo.haiku.color, context: "Haiku model color")
        ]
        
        let backgrounds = [
            Color.backgroundPrimary,
            Color.backgroundSecondary,
            Color(NSColor.controlBackgroundColor)
        ]
        
        for modelTest in modelColorTests {
            for background in backgrounds {
                // When - Calculating contrast ratio
                let contrastRatio = calculateContrastRatio(
                    foreground: modelTest.color,
                    background: background
                )
                
                // Then - Should meet accessibility requirements
                XCTAssertGreaterThanOrEqual(contrastRatio, 3.0, 
                                           "\(modelTest.context) should have sufficient contrast against background, got \(contrastRatio):1")
            }
        }
    }
    
    func testProgressBarContrast() {
        // Given - Progress bar colors against different backgrounds
        let progressTests = [
            (progress: ModelInfo.opus.color, background: Color.gray.opacity(0.2), context: "Opus progress on gray"),
            (progress: ModelInfo.sonnet.color, background: Color.gray.opacity(0.2), context: "Sonnet progress on gray"),
            (progress: ModelInfo.haiku.color, background: Color.gray.opacity(0.2), context: "Haiku progress on gray")
        ]
        
        for test in progressTests {
            // When - Calculating contrast ratio
            let contrastRatio = calculateContrastRatio(
                foreground: test.progress,
                background: test.background
            )
            
            // Then - Should have sufficient contrast for progress indication
            XCTAssertGreaterThanOrEqual(contrastRatio, 3.0, 
                                       "\(test.context) should have sufficient contrast for progress bars, got \(contrastRatio):1")
        }
    }
    
    func testFocusIndicatorContrast() {
        // Given - Focus indicators
        let focusIndicatorColor = Color.blue // Typical focus indicator color
        let backgrounds = [
            Color.white,
            Color.black,
            Color.backgroundPrimary,
            Color.backgroundSecondary
        ]
        
        for background in backgrounds {
            // When - Calculating contrast ratio for focus indicator
            let contrastRatio = calculateContrastRatio(
                foreground: focusIndicatorColor,
                background: background
            )
            
            // Then - Should meet WCAG 2.1 AA requirements for UI components (3:1)
            XCTAssertGreaterThanOrEqual(contrastRatio, 3.0, 
                                       "Focus indicator should have sufficient contrast against background, got \(contrastRatio):1")
        }
    }
    
    func testHighContrastModeSupport() {
        // Given - High contrast mode enabled
        let isHighContrastEnabled = AccessibilitySystem.HighContrast.isEnabled
        
        if isHighContrastEnabled {
            // When - Testing high contrast adjustments
            let adjustedColors = [
                AccessibilitySystem.HighContrast.adjustedColor(Color.blue),
                AccessibilitySystem.HighContrast.adjustedColor(Color.red),
                AccessibilitySystem.HighContrast.adjustedColor(Color.green)
            ]
            
            let borderWidth = AccessibilitySystem.HighContrast.borderWidth()
            let shadowOpacity = AccessibilitySystem.HighContrast.shadowOpacity()
            
            // Then - Should provide enhanced contrast
            for adjustedColor in adjustedColors {
                let contrastRatio = calculateContrastRatio(
                    foreground: adjustedColor,
                    background: Color.white
                )
                XCTAssertGreaterThanOrEqual(contrastRatio, 4.5, 
                                           "High contrast adjusted colors should meet enhanced requirements")
            }
            
            XCTAssertGreaterThanOrEqual(borderWidth, 2.0, "High contrast should use thicker borders")
            XCTAssertGreaterThanOrEqual(shadowOpacity, 0.8, "High contrast should use stronger shadows")
        }
    }
    
    // MARK: - Theme Contrast Tests
    
    func testDarkModeContrast() {
        // Given - Dark mode enabled
        themeManager.currentTheme = DarkTheme()
        
        let darkModeTests = [
            (foreground: themeManager.currentTheme.text, background: themeManager.currentTheme.background, context: "Dark mode text"),
            (foreground: themeManager.currentTheme.secondaryText, background: themeManager.currentTheme.background, context: "Dark mode secondary text"),
            (foreground: themeManager.currentTheme.accent, background: themeManager.currentTheme.background, context: "Dark mode accent")
        ]
        
        for test in darkModeTests {
            // When - Calculating contrast ratio
            let contrastRatio = calculateContrastRatio(
                foreground: test.foreground,
                background: test.background
            )
            
            // Then - Should meet contrast requirements
            XCTAssertGreaterThanOrEqual(contrastRatio, 4.5, 
                                       "\(test.context) should meet WCAG 2.1 AA contrast requirement, got \(contrastRatio):1")
        }
    }
    
    func testLightModeContrast() {
        // Given - Light mode enabled
        themeManager.currentTheme = LightTheme()
        
        let lightModeTests = [
            (foreground: themeManager.currentTheme.text, background: themeManager.currentTheme.background, context: "Light mode text"),
            (foreground: themeManager.currentTheme.secondaryText, background: themeManager.currentTheme.background, context: "Light mode secondary text"),
            (foreground: themeManager.currentTheme.accent, background: themeManager.currentTheme.background, context: "Light mode accent")
        ]
        
        for test in lightModeTests {
            // When - Calculating contrast ratio
            let contrastRatio = calculateContrastRatio(
                foreground: test.foreground,
                background: test.background
            )
            
            // Then - Should meet contrast requirements
            XCTAssertGreaterThanOrEqual(contrastRatio, 4.5, 
                                       "\(test.context) should meet WCAG 2.1 AA contrast requirement, got \(contrastRatio):1")
        }
    }
    
    // MARK: - Interactive Element Contrast Tests
    
    func testButtonContrast() {
        // Given - Button colors
        let buttonTests = [
            (text: Color.white, background: Color.blue, context: "Primary button"),
            (text: Color.blue, background: Color.clear, border: Color.blue, context: "Secondary button"),
            (text: Color.gray, background: Color.clear, context: "Tertiary button")
        ]
        
        for test in buttonTests {
            // When - Calculating text contrast
            let textContrastRatio = calculateContrastRatio(
                foreground: test.text,
                background: test.background == Color.clear ? Color.backgroundPrimary : test.background
            )
            
            // Then - Should meet contrast requirements
            XCTAssertGreaterThanOrEqual(textContrastRatio, 4.5, 
                                       "\(test.context) text should meet WCAG 2.1 AA contrast requirement, got \(textContrastRatio):1")
            
            // Test border contrast if applicable
            if let borderColor = test.border {
                let borderContrastRatio = calculateContrastRatio(
                    foreground: borderColor,
                    background: Color.backgroundPrimary
                )
                XCTAssertGreaterThanOrEqual(borderContrastRatio, 3.0, 
                                           "\(test.context) border should meet WCAG 2.1 AA UI component contrast requirement")
            }
        }
    }
    
    func testStatusIndicatorContrast() {
        // Given - Status indicator colors
        let statusTests = [
            (color: Color.statusSuccess, context: "Success status"),
            (color: Color.statusWarning, context: "Warning status"),
            (color: Color.statusCritical, context: "Critical status"),
            (color: Color.statusInfo, context: "Info status"),
            (color: Color.statusNeutral, context: "Neutral status")
        ]
        
        for test in statusTests {
            // When - Calculating contrast against white and dark backgrounds
            let whiteBackgroundContrast = calculateContrastRatio(
                foreground: test.color,
                background: Color.white
            )
            let darkBackgroundContrast = calculateContrastRatio(
                foreground: test.color,
                background: Color.black
            )
            
            // Then - Should work on at least one background
            let hasAcceptableContrast = whiteBackgroundContrast >= 3.0 || darkBackgroundContrast >= 3.0
            XCTAssertTrue(hasAcceptableContrast, 
                         "\(test.context) should have acceptable contrast on at least one background")
        }
    }
    
    // MARK: - Edge Case Tests
    
    func testMinimumContrastRequirements() {
        // Given - Edge case colors near the minimum threshold
        let edgeCaseTests = [
            (foreground: Color(red: 0.4, green: 0.4, blue: 0.4), background: Color.white, minimumRatio: 4.5),
            (foreground: Color(red: 0.6, green: 0.6, blue: 0.6), background: Color.black, minimumRatio: 4.5),
            (foreground: Color(red: 0.5, green: 0.5, blue: 0.5), background: Color.white, minimumRatio: 3.0) // Large text
        ]
        
        for (index, test) in edgeCaseTests.enumerated() {
            // When - Calculating contrast ratio
            let contrastRatio = calculateContrastRatio(
                foreground: test.foreground,
                background: test.background
            )
            
            // Then - Should meet minimum requirements
            if contrastRatio < test.minimumRatio {
                XCTFail("Edge case \(index + 1) fails minimum contrast requirement: \(contrastRatio):1 < \(test.minimumRatio):1")
            }
        }
    }
    
    func testColorBlindnessSupport() {
        // Given - Colors that should be distinguishable for color blind users
        let colorPairs = [
            (ModelInfo.opus.color, ModelInfo.sonnet.color, "Opus vs Sonnet"),
            (ModelInfo.sonnet.color, ModelInfo.haiku.color, "Sonnet vs Haiku"),
            (Color.statusSuccess, Color.statusCritical, "Success vs Critical"),
            (Color.statusWarning, Color.statusCritical, "Warning vs Critical")
        ]
        
        for (color1, color2, context) in colorPairs {
            // When - Testing color differentiation
            let luminanceDifference = abs(
                calculateRelativeLuminance(color1) - calculateRelativeLuminance(color2)
            )
            
            // Then - Should have sufficient luminance difference for color blind users
            XCTAssertGreaterThan(luminanceDifference, 0.1, 
                                "\(context) should have sufficient luminance difference for color blind users")
        }
    }
    
    // MARK: - Performance Tests
    
    func testContrastCalculationPerformance() {
        measure {
            // When - Calculating many contrast ratios
            for i in 0..<1000 {
                let foreground = Color(red: Double(i % 255) / 255.0, green: 0.5, blue: 0.5)
                let background = Color.white
                _ = calculateContrastRatio(foreground: foreground, background: background)
            }
        }
        
        // Then - Should complete within reasonable time
        // Performance test automatically verifies timing
    }
    
    // MARK: - Helper Methods
    
    private func calculateContrastRatio(foreground: Color, background: Color) -> Double {
        let foregroundLuminance = calculateRelativeLuminance(foreground)
        let backgroundLuminance = calculateRelativeLuminance(background)
        
        let lighter = max(foregroundLuminance, backgroundLuminance)
        let darker = min(foregroundLuminance, backgroundLuminance)
        
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func calculateRelativeLuminance(_ color: Color) -> Double {
        // Extract RGB components from SwiftUI Color
        let rgb = extractRGBComponents(from: color)
        
        // Apply gamma correction
        let r = rgb.red <= 0.04045 ? rgb.red / 12.92 : pow((rgb.red + 0.055) / 1.055, 2.4)
        let g = rgb.green <= 0.04045 ? rgb.green / 12.92 : pow((rgb.green + 0.055) / 1.055, 2.4)
        let b = rgb.blue <= 0.04045 ? rgb.blue / 12.92 : pow((rgb.blue + 0.055) / 1.055, 2.4)
        
        // Calculate relative luminance using sRGB coefficients
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func extractRGBComponents(from color: Color) -> (red: Double, green: Double, blue: Double) {
        // Convert SwiftUI Color to NSColor for component extraction
        let nsColor = NSColor(color)
        
        // Convert to sRGB color space if needed
        guard let srgbColor = nsColor.usingColorSpace(.sRGB) else {
            // Fallback to original color if conversion fails
            return (red: Double(nsColor.redComponent), 
                   green: Double(nsColor.greenComponent), 
                   blue: Double(nsColor.blueComponent))
        }
        
        return (red: Double(srgbColor.redComponent), 
               green: Double(srgbColor.greenComponent), 
               blue: Double(srgbColor.blueComponent))
    }
    
    // MARK: - Mock Theme Classes for Testing
    
    private class LightTheme: ThemeProtocol {
        var appearance: NSAppearance? = NSAppearance(named: .aqua)
        var background: Color = Color.white
        var secondaryBackground: Color = Color(red: 0.95, green: 0.95, blue: 0.95)
        var text: Color = Color.black
        var secondaryText: Color = Color(red: 0.3, green: 0.3, blue: 0.3)
        var tertiaryText: Color = Color(red: 0.5, green: 0.5, blue: 0.5)
        var accent: Color = Color.blue
        var border: Color = Color(red: 0.8, green: 0.8, blue: 0.8)
    }
    
    private class DarkTheme: ThemeProtocol {
        var appearance: NSAppearance? = NSAppearance(named: .darkAqua)
        var background: Color = Color(red: 0.1, green: 0.1, blue: 0.1)
        var secondaryBackground: Color = Color(red: 0.15, green: 0.15, blue: 0.15)
        var text: Color = Color.white
        var secondaryText: Color = Color(red: 0.8, green: 0.8, blue: 0.8)
        var tertiaryText: Color = Color(red: 0.6, green: 0.6, blue: 0.6)
        var accent: Color = Color(red: 0.3, green: 0.6, blue: 1.0)
        var border: Color = Color(red: 0.3, green: 0.3, blue: 0.3)
    }
}

// MARK: - Protocol for Theme Testing

private protocol ThemeProtocol {
    var appearance: NSAppearance? { get }
    var background: Color { get }
    var secondaryBackground: Color { get }
    var text: Color { get }
    var secondaryText: Color { get }
    var tertiaryText: Color { get }
    var accent: Color { get }
    var border: Color { get }
}