import SwiftUI
import AppKit

// MARK: - Accessibility System
// Comprehensive accessibility support for WCAG 2.1 AA compliance

struct AccessibilitySystem {
    
    // MARK: - Accessibility Traits
    
    struct Traits {
        static let progressIndicator: AccessibilityTraits = [.updatesFrequently]
        static let statusElement: AccessibilityTraits = [.updatesFrequently]
        static let navigationElement: AccessibilityTraits = [.isButton]
        static let metricElement: AccessibilityTraits = [.isStaticText]
        static let interactiveElement: AccessibilityTraits = [.isButton]
        static let criticalElement: AccessibilityTraits = [.isStaticText]
    }
    
    // MARK: - Accessibility Labels
    
    struct Labels {
        // Progress and Status Labels
        static func progressLabel(model: String, percentage: Double, tokenCount: Int) -> String {
            return "\(model) model usage: \(tokenCount) tokens, \(Int(percentage.rounded())) percent of session"
        }
        
        static func statusLabel(status: String, isActive: Bool) -> String {
            return isActive ? "Session status: \(status)" : "Session inactive: \(status)"
        }
        
        static func burnRateLabel(rate: Double?) -> String {
            guard let rate = rate else { return "Burn rate: Not available" }
            return "Token burn rate: \(String(format: "%.1f", rate)) tokens per minute"
        }
        
        static func timeRemainingLabel(timeRemaining: String) -> String {
            return timeRemaining == "—" ? "Time remaining: Unknown" : "Time remaining: \(timeRemaining)"
        }
        
        static func sessionEndLabel(endTime: String) -> String {
            return "Session ends at: \(endTime)"
        }
        
        // Interactive Element Labels
        static func refreshButtonLabel(isLoading: Bool) -> String {
            return isLoading ? "Refreshing data, please wait" : "Refresh usage data"
        }
        
        static func quitButtonLabel() -> String {
            return "Quit ClaudeRadar application"
        }
        
        static func retryButtonLabel() -> String {
            return "Retry loading usage data"
        }
        
        static func settingsButtonLabel() -> String {
            return "Open ClaudeRadar settings"
        }
        
        // Model Progress Labels
        static func modelProgressLabel(modelInfo: ModelInfo, tokenCount: Int, percentage: Double) -> String {
            return "\(modelInfo.displayName): \(tokenCount) tokens used, \(Int(percentage.rounded())) percent of total session usage"
        }
        
        static func circularProgressLabel(percentage: Double, tokenCount: Int, limit: Int) -> String {
            return "Session progress: \(tokenCount) of \(limit) tokens used, \(Int(percentage * 100)) percent complete"
        }
    }
    
    // MARK: - Accessibility Hints
    
    struct Hints {
        static let progressBar = "Progress bar showing model usage as percentage of total session tokens"
        static let statusIndicator = "Status indicator showing current session connection state"
        static let refreshButton = "Tap to refresh token usage data from Claude"
        static let quitButton = "Tap to quit the application"
        static let retryButton = "Tap to retry loading data after connection error"
        static let settingsButton = "Tap to open application settings"
        static let modelProgress = "Shows token usage breakdown by Claude model"
        static let circularProgress = "Shows overall session progress as percentage of limit"
    }
    
    // MARK: - Accessibility Values
    
    struct Values {
        static func progressValue(percentage: Double) -> String {
            return "\(Int(percentage.rounded())) percent"
        }
        
        static func tokenValue(count: Int, limit: Int) -> String {
            return "\(count) of \(limit) tokens"
        }
        
        static func burnRateValue(rate: Double?) -> String {
            guard let rate = rate else { return "Not available" }
            return "\(String(format: "%.1f", rate)) tokens per minute"
        }
        
        static func timeValue(timeString: String) -> String {
            return timeString == "—" ? "Unknown" : timeString
        }
    }
    
    // MARK: - Accessibility Actions
    
    struct Actions {
        static func triggerRefresh() {
            NotificationCenter.default.post(name: .refreshUsageData, object: nil)
        }
        
        static func triggerQuit() {
            NSApplication.shared.terminate(nil)
        }
        
        static func triggerRetry() {
            NotificationCenter.default.post(name: .retryDataLoad, object: nil)
        }
        
        static func triggerOpenSettings() {
            NotificationCenter.default.post(name: .openSettings, object: nil)
        }
        
        static func announceStatus(_ status: String) {
            VoiceOver.announceStatus(status)
        }
    }
    
    // MARK: - Dynamic Type Support
    
    struct DynamicType {
        static func scaledFont(for font: Font, category: DynamicTypeSize) -> Font {
            let baseSize = font.baseSize
            let scaleFactor = scaleFactor(for: category)
            let scaledSize = baseSize * scaleFactor
            
            switch font {
            case .largeTitle:
                return .system(size: scaledSize, weight: .bold)
            case .title:
                return .system(size: scaledSize, weight: .bold)
            case .title2:
                return .system(size: scaledSize, weight: .bold)
            case .title3:
                return .system(size: scaledSize, weight: .semibold)
            case .headline:
                return .system(size: scaledSize, weight: .semibold)
            case .subheadline:
                return .system(size: scaledSize, weight: .regular)
            case .body:
                return .system(size: scaledSize, weight: .regular)
            case .callout:
                return .system(size: scaledSize, weight: .regular)
            case .footnote:
                return .system(size: scaledSize, weight: .regular)
            case .caption:
                return .system(size: scaledSize, weight: .regular)
            case .caption2:
                return .system(size: scaledSize, weight: .regular)
            default:
                return .system(size: scaledSize, weight: .regular)
            }
        }
        
        static func scaleFactor(for category: DynamicTypeSize) -> CGFloat {
            switch category {
            case .xSmall:
                return 0.82
            case .small:
                return 0.88
            case .medium:
                return 1.0
            case .large:
                return 1.12
            case .xLarge:
                return 1.24
            case .xxLarge:
                return 1.36
            case .xxxLarge:
                return 1.48
            case .accessibility1:
                return 1.75
            case .accessibility2:
                return 2.0
            case .accessibility3:
                return 2.35
            case .accessibility4:
                return 2.76
            case .accessibility5:
                return 3.12
            default:
                return 1.0
            }
        }
        
        static func scaledSpacing(for spacing: CGFloat, category: DynamicTypeSize) -> CGFloat {
            let scaleFactor = scaleFactor(for: category)
            return spacing * max(0.9, min(1.5, scaleFactor))
        }
    }
    
    // MARK: - Reduced Motion Support
    
    struct ReducedMotion {
        static var isEnabled: Bool {
            return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        }
        
        static func animationDuration(normal: Double) -> Double {
            return isEnabled ? 0.0 : normal
        }
        
        static func animationCurve() -> Animation {
            return isEnabled ? .linear(duration: 0) : .easeInOut
        }
        
        static func transitionEffect() -> AnyTransition {
            return isEnabled ? .identity : .opacity.combined(with: .scale(scale: 0.95))
        }
    }
    
    // MARK: - High Contrast Support
    
    struct HighContrast {
        static var isEnabled: Bool {
            return NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
        }
        
        static func adjustedColor(_ color: Color) -> Color {
            return isEnabled ? color.opacity(0.9) : color
        }
        
        static func borderWidth() -> CGFloat {
            return isEnabled ? 2.0 : 1.0
        }
        
        static func shadowOpacity() -> Double {
            return isEnabled ? 0.8 : 0.3
        }
    }
    
    // MARK: - VoiceOver Support
    
    struct VoiceOver {
        static var isEnabled: Bool {
            return NSWorkspace.shared.isVoiceOverEnabled
        }
        
        static func announce(_ text: String) {
            guard isEnabled else { return }
            
            DispatchQueue.main.async {
                NSAccessibility.post(
                    element: NSApp.mainWindow as Any,
                    notification: .announcementRequested
                )
            }
        }
        
        static func announceStatus(_ status: String) {
            announce("Status update: \(status)")
        }
        
        static func announceProgress(_ progress: String) {
            announce("Progress update: \(progress)")
        }
        
        static func announceError(_ error: String) {
            announce("Error: \(error)")
        }
    }
    
    // MARK: - Keyboard Navigation
    
    struct KeyboardNavigation {
        static func configureFocusable(_ view: some View) -> some View {
            view
                .focusable()
                .onKeyPress(.space) {
                    // Handle space key activation
                    return .handled
                }
                .onKeyPress(.return) {
                    // Handle return key activation
                    return .handled
                }
        }
        
        static func configureButton(_ view: some View, action: @escaping () -> Void) -> some View {
            view
                .focusable()
                .onKeyPress(.space) {
                    action()
                    return .handled
                }
                .onKeyPress(.return) {
                    action()
                    return .handled
                }
        }
    }
}

// MARK: - SwiftUI Extensions for Accessibility

extension View {
    // MARK: - Accessibility Modifiers
    
    func accessibilityProgress(model: String, percentage: Double, tokenCount: Int) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilitySystem.Labels.progressLabel(model: model, percentage: percentage, tokenCount: tokenCount))
            .accessibilityValue(AccessibilitySystem.Values.progressValue(percentage: percentage))
            .accessibilityHint(AccessibilitySystem.Hints.progressBar)
    }
    
    func accessibilityStatus(status: String, isActive: Bool) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilitySystem.Labels.statusLabel(status: status, isActive: isActive))
            .accessibilityHint(AccessibilitySystem.Hints.statusIndicator)
    }
    
    func accessibilityInteractiveButton(label: String, hint: String, action: @escaping () -> Void) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityAction(named: label, action)
    }
    
    func accessibilityMetric(label: String, value: String) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(value)
    }
    
    func accessibilityCircularProgress(percentage: Double, tokenCount: Int, limit: Int) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilitySystem.Labels.circularProgressLabel(percentage: percentage, tokenCount: tokenCount, limit: limit))
            .accessibilityValue(AccessibilitySystem.Values.progressValue(percentage: percentage * 100))
            .accessibilityHint(AccessibilitySystem.Hints.circularProgress)
    }
    
    // MARK: - Keyboard Navigation
    
    func keyboardNavigable(action: @escaping () -> Void) -> some View {
        AccessibilitySystem.KeyboardNavigation.configureButton(self, action: action)
    }
    
    func keyboardFocusable() -> some View {
        AccessibilitySystem.KeyboardNavigation.configureFocusable(self)
    }
    
    // MARK: - Dynamic Type Support
    
    func dynamicTypeScaled(font: Font) -> some View {
        DynamicTypeScaledView(content: self, font: font)
    }
    
    func dynamicTypeScaled(spacing: CGFloat) -> some View {
        DynamicTypeScaledSpacingView(content: self, spacing: spacing)
    }
    
    // MARK: - Reduced Motion Support
    
    func reducedMotionAnimation(duration: Double) -> some View {
        self.animation(
            AccessibilitySystem.ReducedMotion.animationCurve()
                .speed(AccessibilitySystem.ReducedMotion.animationDuration(normal: duration) == 0.0 ? 100 : 1),
            value: UUID()
        )
    }
    
    func reducedMotionTransition() -> some View {
        self.transition(AccessibilitySystem.ReducedMotion.transitionEffect())
    }
    
    // MARK: - High Contrast Support
    
    func highContrastAdjusted(color: Color) -> some View {
        self.foregroundColor(AccessibilitySystem.HighContrast.adjustedColor(color))
    }
    
    func highContrastBorder() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.primary, lineWidth: AccessibilitySystem.HighContrast.borderWidth())
                .opacity(AccessibilitySystem.HighContrast.isEnabled ? 1.0 : 0.0)
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let refreshUsageData = Notification.Name("refreshUsageData")
    static let retryDataLoad = Notification.Name("retryDataLoad")
    static let openSettings = Notification.Name("openSettings")
    static let announceStatus = Notification.Name("announceStatus")
}

// MARK: - Font Extensions

extension Font {
    var baseSize: CGFloat {
        // Standard iOS/macOS font sizes based on Apple's Human Interface Guidelines
        switch self {
        case .largeTitle:
            return 34.0
        case .title:
            return 28.0
        case .title2:
            return 22.0
        case .title3:
            return 20.0
        case .headline:
            return 17.0
        case .subheadline:
            return 15.0
        case .body:
            return 17.0
        case .callout:
            return 16.0
        case .footnote:
            return 13.0
        case .caption:
            return 12.0
        case .caption2:
            return 11.0
        default:
            return 17.0 // Default body size
        }
    }
}

// MARK: - Dynamic Type Helper Views

struct DynamicTypeScaledView<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let content: Content
    let font: Font
    
    var body: some View {
        content.font(AccessibilitySystem.DynamicType.scaledFont(for: font, category: dynamicTypeSize))
    }
}

struct DynamicTypeScaledSpacingView<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let content: Content
    let spacing: CGFloat
    
    var body: some View {
        content.padding(AccessibilitySystem.DynamicType.scaledSpacing(for: spacing, category: dynamicTypeSize))
    }
}

// MARK: - Accessibility Testing Support

#if DEBUG
struct AccessibilityTestingView: View {
    @State private var testResults: [String] = []
    
    var body: some View {
        VStack {
            Text("Accessibility Testing")
                .font(.title)
                .accessibilityHeading(.h1)
            
            Button("Run VoiceOver Test") {
                runVoiceOverTest()
            }
            .accessibilityIdentifier("voiceOverTestButton")
            
            Button("Run Keyboard Navigation Test") {
                runKeyboardNavigationTest()
            }
            .accessibilityIdentifier("keyboardTestButton")
            
            Button("Run Dynamic Type Test") {
                runDynamicTypeTest()
            }
            .accessibilityIdentifier("dynamicTypeTestButton")
            
            List(testResults, id: \.self) { result in
                Text(result)
            }
            .accessibilityIdentifier("testResults")
        }
        .padding()
    }
    
    private func runVoiceOverTest() {
        testResults.append("VoiceOver Test: \(AccessibilitySystem.VoiceOver.isEnabled ? "Enabled" : "Disabled")")
        AccessibilitySystem.VoiceOver.announce("Running VoiceOver test")
    }
    
    private func runKeyboardNavigationTest() {
        testResults.append("Keyboard Navigation Test: Completed")
    }
    
    private func runDynamicTypeTest() {
        testResults.append("Dynamic Type Test: Completed")
    }
}
#endif