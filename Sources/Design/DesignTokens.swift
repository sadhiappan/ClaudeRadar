import Foundation
import SwiftUI

// MARK: - Design Tokens System

struct DesignTokens {
    
    // MARK: - Typography Scale
    
    struct Typography {
        
        // MARK: - Base Font Definitions
        
        static let displayLarge = FontToken(size: 32, weight: .bold, lineHeight: 40)
        static let displayMedium = FontToken(size: 28, weight: .bold, lineHeight: 36)
        static let displaySmall = FontToken(size: 24, weight: .bold, lineHeight: 32)
        
        static let headlineLarge = FontToken(size: 20, weight: .semibold, lineHeight: 28)
        static let headlineMedium = FontToken(size: 18, weight: .semibold, lineHeight: 24)
        static let headlineSmall = FontToken(size: 16, weight: .semibold, lineHeight: 22)
        
        static let bodyLarge = FontToken(size: 16, weight: .regular, lineHeight: 24)
        static let bodyMedium = FontToken(size: 14, weight: .regular, lineHeight: 20)
        static let bodySmall = FontToken(size: 12, weight: .regular, lineHeight: 18)
        
        static let labelLarge = FontToken(size: 14, weight: .medium, lineHeight: 20)
        static let labelMedium = FontToken(size: 12, weight: .medium, lineHeight: 16)
        static let labelSmall = FontToken(size: 10, weight: .medium, lineHeight: 14)
    }
    
    // MARK: - Semantic Font Mappings
    
    struct SemanticFonts {
        // Token count display (main metric)
        static let tokenCount = Typography.displayLarge
        
        // Session status and burn rate
        static let sessionStatus = Typography.headlineMedium
        static let burnRate = Typography.headlineSmall
        
        // Metric values and percentages
        static let metricValue = Typography.bodyLarge
        static let metricLabel = Typography.labelMedium
        
        // Section titles
        static let sectionTitle = Typography.labelLarge
        
        // Supporting text and captions
        static let caption = Typography.bodySmall
        static let footnote = Typography.labelSmall
        
        // App branding
        static let appTitle = Typography.headlineLarge
        static let appSubtitle = Typography.bodyMedium
    }
    
    // MARK: - Spacing Scale
    
    struct Spacing {
        static let xs: CGFloat = 4      // 0.25rem
        static let sm: CGFloat = 8      // 0.5rem
        static let md: CGFloat = 12     // 0.75rem
        static let lg: CGFloat = 16     // 1rem
        static let xl: CGFloat = 20     // 1.25rem
        static let xxl: CGFloat = 24    // 1.5rem
        static let xxxl: CGFloat = 32   // 2rem
        static let xxxxl: CGFloat = 40  // 2.5rem
    }
    
    // MARK: - Semantic Spacing Mappings
    
    struct SemanticSpacing {
        // Component internal spacing
        static let componentPadding = Spacing.md
        static let cardPadding = Spacing.lg
        static let buttonPadding = Spacing.sm
        
        // Layout spacing
        static let sectionSpacing = Spacing.xl
        static let elementSpacing = Spacing.md
        static let tightSpacing = Spacing.xs
        static let looseSpacing = Spacing.xxl
        
        // Specific use cases
        static let progressBarSpacing = Spacing.sm
        static let headerSpacing = Spacing.lg
        static let footerSpacing = Spacing.md
    }
    
    // MARK: - Border Radius Scale
    
    struct BorderRadius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let full: CGFloat = 999  // Fully rounded
    }
    
    // MARK: - Semantic Border Radius Mappings
    
    struct SemanticBorderRadius {
        static let button = BorderRadius.md
        static let card = BorderRadius.lg
        static let input = BorderRadius.sm
        static let progressBar = BorderRadius.full
        static let badge = BorderRadius.full
    }
    
    // MARK: - Shadow System
    
    struct Shadows {
        static let none = ShadowToken(color: .clear, radius: 0, x: 0, y: 0)
        static let sm = ShadowToken(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        static let md = ShadowToken(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        static let lg = ShadowToken(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        static let xl = ShadowToken(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Semantic Shadow Mappings
    
    struct SemanticShadows {
        static let card = Shadows.sm
        static let button = Shadows.none
        static let popover = Shadows.lg
        static let elevated = Shadows.md
    }
    
    // MARK: - Layout Constants
    
    struct Layout {
        // Menu bar dimensions
        static let menuBarWidth: CGFloat = 320
        static let menuBarHeight: CGFloat = 600
        
        // Component sizes
        static let progressBarHeight: CGFloat = 8
        static let circularProgressSize: CGFloat = 60
        static let iconSize: CGFloat = 16
        static let buttonHeight: CGFloat = 32
        
        // Grid and columns
        static let gridColumns: Int = 12
        static let maxContentWidth: CGFloat = 1200
    }
    
    // MARK: - Animation Durations
    
    struct Animation {
        static let fast: Double = 0.15
        static let normal: Double = 0.25
        static let slow: Double = 0.35
        static let veryFast: Double = 0.1
    }
}

// MARK: - Supporting Structures

struct FontToken {
    let size: CGFloat
    let weight: Font.Weight
    let lineHeight: CGFloat
    
    var font: Font {
        return Font.system(size: size, weight: weight)
    }
    
    var uiFont: NSFont {
        let descriptor = NSFontDescriptor.preferredFontDescriptor(forTextStyle: .body)
        return NSFont(descriptor: descriptor, size: size) ?? NSFont.systemFont(ofSize: size)
    }
}

struct ShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - SwiftUI Extensions

extension Font {
    // MARK: - Typography Scale Access
    
    static var displayLarge: Font { DesignTokens.Typography.displayLarge.font }
    static var displayMedium: Font { DesignTokens.Typography.displayMedium.font }
    static var displaySmall: Font { DesignTokens.Typography.displaySmall.font }
    
    static var headlineLarge: Font { DesignTokens.Typography.headlineLarge.font }
    static var headlineMedium: Font { DesignTokens.Typography.headlineMedium.font }
    static var headlineSmall: Font { DesignTokens.Typography.headlineSmall.font }
    
    static var bodyLarge: Font { DesignTokens.Typography.bodyLarge.font }
    static var bodyMedium: Font { DesignTokens.Typography.bodyMedium.font }
    static var bodySmall: Font { DesignTokens.Typography.bodySmall.font }
    
    static var labelLarge: Font { DesignTokens.Typography.labelLarge.font }
    static var labelMedium: Font { DesignTokens.Typography.labelMedium.font }
    static var labelSmall: Font { DesignTokens.Typography.labelSmall.font }
    
    // MARK: - Semantic Font Access
    
    static var semanticTokenCount: Font { DesignTokens.SemanticFonts.tokenCount.font }
    static var semanticSessionStatus: Font { DesignTokens.SemanticFonts.sessionStatus.font }
    static var semanticBurnRate: Font { DesignTokens.SemanticFonts.burnRate.font }
    static var semanticMetricValue: Font { DesignTokens.SemanticFonts.metricValue.font }
    static var semanticMetricLabel: Font { DesignTokens.SemanticFonts.metricLabel.font }
    static var semanticSectionTitle: Font { DesignTokens.SemanticFonts.sectionTitle.font }
    static var semanticCaption: Font { DesignTokens.SemanticFonts.caption.font }
    static var semanticFootnote: Font { DesignTokens.SemanticFonts.footnote.font }
    static var semanticAppTitle: Font { DesignTokens.SemanticFonts.appTitle.font }
    static var semanticAppSubtitle: Font { DesignTokens.SemanticFonts.appSubtitle.font }
}

extension CGFloat {
    // MARK: - Spacing Scale Access
    
    static var spacingXs: CGFloat { DesignTokens.Spacing.xs }
    static var spacingSm: CGFloat { DesignTokens.Spacing.sm }
    static var spacingMd: CGFloat { DesignTokens.Spacing.md }
    static var spacingLg: CGFloat { DesignTokens.Spacing.lg }
    static var spacingXl: CGFloat { DesignTokens.Spacing.xl }
    static var spacingXxl: CGFloat { DesignTokens.Spacing.xxl }
    static var spacingXxxl: CGFloat { DesignTokens.Spacing.xxxl }
    
    // MARK: - Semantic Spacing Access
    
    static var componentPadding: CGFloat { DesignTokens.SemanticSpacing.componentPadding }
    static var cardPadding: CGFloat { DesignTokens.SemanticSpacing.cardPadding }
    static var sectionSpacing: CGFloat { DesignTokens.SemanticSpacing.sectionSpacing }
    static var elementSpacing: CGFloat { DesignTokens.SemanticSpacing.elementSpacing }
    
    // MARK: - Border Radius Access
    
    static var radiusNone: CGFloat { DesignTokens.BorderRadius.none }
    static var radiusSm: CGFloat { DesignTokens.BorderRadius.sm }
    static var radiusMd: CGFloat { DesignTokens.BorderRadius.md }
    static var radiusLg: CGFloat { DesignTokens.BorderRadius.lg }
    static var radiusXl: CGFloat { DesignTokens.BorderRadius.xl }
    static var radiusFull: CGFloat { DesignTokens.BorderRadius.full }
    
    // MARK: - Semantic Radius Access
    
    static var buttonRadius: CGFloat { DesignTokens.SemanticBorderRadius.button }
    static var cardRadius: CGFloat { DesignTokens.SemanticBorderRadius.card }
    static var inputRadius: CGFloat { DesignTokens.SemanticBorderRadius.input }
    static var progressBarRadius: CGFloat { DesignTokens.SemanticBorderRadius.progressBar }
}

extension View {
    // MARK: - Shadow Modifiers
    
    func shadowToken(_ token: ShadowToken) -> some View {
        self.shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)
    }
    
    func cardShadow() -> some View {
        self.shadowToken(DesignTokens.SemanticShadows.card)
    }
    
    func elevatedShadow() -> some View {
        self.shadowToken(DesignTokens.SemanticShadows.elevated)
    }
    
    func popoverShadow() -> some View {
        self.shadowToken(DesignTokens.SemanticShadows.popover)
    }
    
    // MARK: - Spacing Modifiers
    
    func componentPadding() -> some View {
        self.padding(.componentPadding)
    }
    
    func cardPadding() -> some View {
        self.padding(.cardPadding)
    }
    
    func sectionSpacing() -> some View {
        self.padding(.vertical, .sectionSpacing)
    }
}