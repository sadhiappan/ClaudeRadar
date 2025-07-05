import SwiftUI

// MARK: - Design System
// Centralized design tokens following the feedback from UI/UX review

// MARK: - Typography Scale
extension Font {
    // Primary metrics and important data
    static let tokenCount = Font.largeTitle.bold()
    
    // Secondary headings and status messages
    static let sessionStatus = Font.headline.weight(.medium)
    
    // Metric values in compact displays
    static let metricValue = Font.body.weight(.semibold)
    
    // Metric labels and secondary text
    static let metricLabel = Font.caption.weight(.regular)
    
    // Footer text and timestamps
    static let footerText = Font.caption2.weight(.regular)
    
    // App title and headers
    static let appTitle = Font.callout.weight(.semibold)
    
    // Subtitles and descriptions
    static let appSubtitle = Font.caption2.weight(.regular)
    
}

// MARK: - Color System
extension Color {
    // Status colors
    static let statusSuccess = Color.green
    static let statusWarning = Color.orange
    static let statusCritical = Color.red
    static let statusInfo = Color.blue
    static let statusNeutral = Color.purple
    
    // Background colors
    static let backgroundPrimary = Color(NSColor.controlBackgroundColor)
    static let backgroundSecondary = Color(NSColor.controlBackgroundColor).opacity(0.3)
    
    // Text colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    // Accent colors for icons
    static let accentOrange = Color.orange
    static let accentBlue = Color.blue
    static let accentPurple = Color.purple
    static let accentGreen = Color.green
}

// MARK: - Spacing Scale
extension CGFloat {
    // Consistent spacing system
    static let spacing1: CGFloat = 4   // Minimal spacing
    static let spacing2: CGFloat = 8   // Standard spacing
    static let spacing3: CGFloat = 12  // Medium spacing
    static let spacing4: CGFloat = 16  // Large spacing
    static let spacing5: CGFloat = 24  // Extra large spacing
}

// MARK: - Component Sizes
extension CGFloat {
    // Standard component dimensions
    static let progressCircleSize: CGFloat = 40
    static let statusIndicatorSize: CGFloat = 12
    static let iconFrameSize: CGFloat = 12
    
    // Corner radius
    static let cornerRadiusSmall: CGFloat = 4
    static let cornerRadiusMedium: CGFloat = 6
    static let cornerRadiusLarge: CGFloat = 8
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @State private var isHovered: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isHovered ? .accentBlue : .textPrimary)
            .padding(.horizontal, .spacing2)
            .padding(.vertical, .spacing1)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                    .fill(isHovered ? Color.backgroundSecondary : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                            .stroke(isHovered ? Color.accentBlue : Color.textSecondary, lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .animation(
                AccessibilitySystem.ReducedMotion.isEnabled 
                    ? .linear(duration: 0) 
                    : .easeOut(duration: DesignTokens.Animation.fast), 
                value: isHovered
            )
            .animation(
                AccessibilitySystem.ReducedMotion.isEnabled 
                    ? .linear(duration: 0) 
                    : .easeOut(duration: DesignTokens.Animation.veryFast), 
                value: configuration.isPressed
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct TertiaryButtonStyle: ButtonStyle {
    @State private var isHovered: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isHovered ? .accentBlue : .textSecondary)
            .padding(.horizontal, .spacing2)
            .padding(.vertical, .spacing1)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                    .fill(isHovered ? Color.backgroundSecondary : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovered ? 1.02 : 1.0))
            .animation(
                AccessibilitySystem.ReducedMotion.isEnabled 
                    ? .linear(duration: 0) 
                    : .easeOut(duration: DesignTokens.Animation.fast), 
                value: isHovered
            )
            .animation(
                AccessibilitySystem.ReducedMotion.isEnabled 
                    ? .linear(duration: 0) 
                    : .easeOut(duration: DesignTokens.Animation.veryFast), 
                value: configuration.isPressed
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

struct HoverButtonStyle: ButtonStyle {
    @State private var isHovered: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isHovered ? .accentBlue : .textSecondary)
            .background(
                RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                    .fill(isHovered ? Color.backgroundSecondary : Color.clear)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : (isHovered ? 1.05 : 1.0))
            .animation(
                AccessibilitySystem.ReducedMotion.isEnabled 
                    ? .linear(duration: 0) 
                    : .easeOut(duration: DesignTokens.Animation.fast), 
                value: isHovered
            )
            .animation(
                AccessibilitySystem.ReducedMotion.isEnabled 
                    ? .linear(duration: 0) 
                    : .easeOut(duration: DesignTokens.Animation.veryFast), 
                value: configuration.isPressed
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }
}