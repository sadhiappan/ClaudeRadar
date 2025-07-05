import XCTest
import SwiftUI
@testable import ClaudeRadar

class TypographySystemTests: XCTestCase {
    
    // MARK: - Typography Scale Tests
    
    func testTypographyScaleDefinition() {
        // Given - Typography scale
        let typography = DesignTokens.Typography.self
        
        // Then - Should have all semantic font sizes
        XCTAssertNotNil(typography.displayLarge)
        XCTAssertNotNil(typography.displayMedium)
        XCTAssertNotNil(typography.displaySmall)
        XCTAssertNotNil(typography.headlineLarge)
        XCTAssertNotNil(typography.headlineMedium)
        XCTAssertNotNil(typography.headlineSmall)
        XCTAssertNotNil(typography.bodyLarge)
        XCTAssertNotNil(typography.bodyMedium)
        XCTAssertNotNil(typography.bodySmall)
        XCTAssertNotNil(typography.labelLarge)
        XCTAssertNotNil(typography.labelMedium)
        XCTAssertNotNil(typography.labelSmall)
    }
    
    func testTypographyHierarchy() {
        // Given - Typography sizes
        let typography = DesignTokens.Typography.self
        
        // Then - Display should be largest
        XCTAssertTrue(typography.displayLarge.size > typography.headlineLarge.size)
        XCTAssertTrue(typography.headlineLarge.size > typography.bodyLarge.size)
        XCTAssertTrue(typography.bodyLarge.size > typography.labelLarge.size)
    }
    
    func testSemanticFontMapping() {
        // Given - Semantic font mappings
        let semanticFonts = DesignTokens.SemanticFonts.self
        
        // Then - Should map to appropriate typography tokens
        XCTAssertNotNil(semanticFonts.tokenCount)
        XCTAssertNotNil(semanticFonts.sessionStatus)
        XCTAssertNotNil(semanticFonts.metricValue)
        XCTAssertNotNil(semanticFonts.metricLabel)
        XCTAssertNotNil(semanticFonts.sectionTitle)
        XCTAssertNotNil(semanticFonts.caption)
    }
    
    // MARK: - Spacing Scale Tests
    
    func testSpacingScaleDefinition() {
        // Given - Spacing scale
        let spacing = DesignTokens.Spacing.self
        
        // Then - Should have full spacing scale
        XCTAssertEqual(spacing.xs, 4)
        XCTAssertEqual(spacing.sm, 8)
        XCTAssertEqual(spacing.md, 12)
        XCTAssertEqual(spacing.lg, 16)
        XCTAssertEqual(spacing.xl, 20)
        XCTAssertEqual(spacing.xxl, 24)
        XCTAssertEqual(spacing.xxxl, 32)
    }
    
    func testSpacingProgression() {
        // Given - Spacing values
        let spacing = DesignTokens.Spacing.self
        
        // Then - Should have logical progression
        XCTAssertTrue(spacing.xs < spacing.sm)
        XCTAssertTrue(spacing.sm < spacing.md)
        XCTAssertTrue(spacing.md < spacing.lg)
        XCTAssertTrue(spacing.lg < spacing.xl)
        XCTAssertTrue(spacing.xl < spacing.xxl)
        XCTAssertTrue(spacing.xxl < spacing.xxxl)
    }
    
    func testSemanticSpacingMapping() {
        // Given - Semantic spacing mappings
        let semanticSpacing = DesignTokens.SemanticSpacing.self
        
        // Then - Should provide semantic access to spacing
        XCTAssertNotNil(semanticSpacing.componentPadding)
        XCTAssertNotNil(semanticSpacing.sectionSpacing)
        XCTAssertNotNil(semanticSpacing.cardPadding)
        XCTAssertNotNil(semanticSpacing.elementSpacing)
        XCTAssertNotNil(semanticSpacing.tightSpacing)
        XCTAssertNotNil(semanticSpacing.looseSpacing)
    }
    
    // MARK: - Border Radius Tests
    
    func testBorderRadiusScale() {
        // Given - Border radius scale
        let radius = DesignTokens.BorderRadius.self
        
        // Then - Should have appropriate radius values
        XCTAssertEqual(radius.none, 0)
        XCTAssertEqual(radius.sm, 4)
        XCTAssertEqual(radius.md, 8)
        XCTAssertEqual(radius.lg, 12)
        XCTAssertEqual(radius.xl, 16)
        XCTAssertEqual(radius.full, 999)
    }
    
    func testSemanticRadiusMapping() {
        // Given - Semantic radius mappings
        let semanticRadius = DesignTokens.SemanticBorderRadius.self
        
        // Then - Should provide semantic access to radius
        XCTAssertNotNil(semanticRadius.button)
        XCTAssertNotNil(semanticRadius.card)
        XCTAssertNotNil(semanticRadius.input)
        XCTAssertNotNil(semanticRadius.progressBar)
    }
    
    // MARK: - Shadow System Tests
    
    func testShadowDefinitions() {
        // Given - Shadow system
        let shadows = DesignTokens.Shadows.self
        
        // Then - Should define appropriate shadow levels
        XCTAssertNotNil(shadows.none)
        XCTAssertNotNil(shadows.sm)
        XCTAssertNotNil(shadows.md) 
        XCTAssertNotNil(shadows.lg)
        XCTAssertNotNil(shadows.xl)
    }
    
    func testSemanticShadowMapping() {
        // Given - Semantic shadow mappings
        let semanticShadows = DesignTokens.SemanticShadows.self
        
        // Then - Should provide semantic access to shadows
        XCTAssertNotNil(semanticShadows.card)
        XCTAssertNotNil(semanticShadows.button)
        XCTAssertNotNil(semanticShadows.popover)
        XCTAssertNotNil(semanticShadows.elevated)
    }
    
    // MARK: - Layout Tests
    
    func testLayoutConstraints() {
        // Given - Layout constraints
        let layout = DesignTokens.Layout.self
        
        // Then - Should define consistent layout values
        XCTAssertEqual(layout.menuBarWidth, 280)
        XCTAssertEqual(layout.menuBarHeight, 600)
        XCTAssertEqual(layout.progressBarHeight, 8)
        XCTAssertEqual(layout.circularProgressSize, 60)
    }
    
    // MARK: - Integration Tests
    
    func testDesignTokensIntegration() {
        // Given - Complete design tokens system
        let tokens = DesignTokens.self
        
        // Then - Should integrate all subsystems
        XCTAssertNotNil(tokens.Typography.self)
        XCTAssertNotNil(tokens.Spacing.self)
        XCTAssertNotNil(tokens.BorderRadius.self)
        XCTAssertNotNil(tokens.Shadows.self)
        XCTAssertNotNil(tokens.Layout.self)
    }
    
    func testSwiftUIExtensionsIntegration() {
        // Given - SwiftUI extensions
        let testFont = Font.semanticTokenCount
        let testSpacing = CGFloat.spacingMd
        
        // Then - Should provide convenient access
        XCTAssertNotNil(testFont)
        XCTAssertEqual(testSpacing, 12)
    }
}