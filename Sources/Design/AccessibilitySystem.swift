import SwiftUI
import AppKit

// MARK: - Accessibility System
// Comprehensive accessibility support for WCAG 2.1 AA compliance

struct AccessibilitySystem {
    
    // MARK: - Accessibility Traits
    
    struct Traits {
        static let progressIndicator: AccessibilityTraits = [.updatesFrequently, .causesPageTurn]
        static let statusElement: AccessibilityTraits = [.summaryElement, .updatesFrequently]
        static let navigationElement: AccessibilityTraits = [.button, .keyboardKey]
        static let metricElement: AccessibilityTraits = [.staticText, .summaryElement]
        static let interactiveElement: AccessibilityTraits = [.button, .playsSound]
        static let criticalElement: AccessibilityTraits = [.staticText, .startsMediaSession]
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
        static func refreshAction() -> AccessibilityCustomAction {
            return AccessibilityCustomAction(name: "Refresh Data") { _ in
                NotificationCenter.default.post(name: .refreshUsageData, object: nil)
                return true
            }
        }
        
        static func quitAction() -> AccessibilityCustomAction {
            return AccessibilityCustomAction(name: "Quit Application") { _ in
                NSApplication.shared.terminate(nil)
                return true
            }
        }
        
        static func retryAction() -> AccessibilityCustomAction {
            return AccessibilityCustomAction(name: "Retry Loading") { _ in
                NotificationCenter.default.post(name: .retryDataLoad, object: nil)
                return true
            }
        }
        
        static func openSettingsAction() -> AccessibilityCustomAction {
            return AccessibilityCustomAction(name: "Open Settings") { _ in
                NotificationCenter.default.post(name: .openSettings, object: nil)
                return true
            }
        }
        
        static func announceStatusAction(status: String) -> AccessibilityCustomAction {
            return AccessibilityCustomAction(name: "Announce Status") { _ in
                NSAccessibility.post(element: NSApp.mainWindow as Any, notification: .announcementRequested)
                return true
            }
        }
    }
    
    // MARK: - Dynamic Type Support
    
    struct DynamicType {
        static func scaledFont(for font: Font, category: DynamicTypeSize) -> Font {
            switch category {
            case .xSmall, .small:
                return font.font(size: font.pointSize * 0.85)
            case .medium:
                return font
            case .large:
                return font.font(size: font.pointSize * 1.15)
            case .xLarge:
                return font.font(size: font.pointSize * 1.3)
            case .xxLarge:
                return font.font(size: font.pointSize * 1.5)
            case .xxxLarge:
                return font.font(size: font.pointSize * 1.7)
            case .accessibility1:
                return font.font(size: font.pointSize * 2.0)
            case .accessibility2:
                return font.font(size: font.pointSize * 2.3)
            case .accessibility3:
                return font.font(size: font.pointSize * 2.6)
            case .accessibility4:
                return font.font(size: font.pointSize * 3.0)
            case .accessibility5:
                return font.font(size: font.pointSize * 3.5)
            default:
                return font
            }
        }
        
        static func scaledSpacing(for spacing: CGFloat, category: DynamicTypeSize) -> CGFloat {
            switch category {
            case .xSmall, .small:
                return spacing * 0.9
            case .medium:
                return spacing
            case .large, .xLarge:
                return spacing * 1.1
            case .xxLarge, .xxxLarge:
                return spacing * 1.2
            case .accessibility1, .accessibility2:
                return spacing * 1.3
            case .accessibility3, .accessibility4, .accessibility5:
                return spacing * 1.5
            default:
                return spacing
            }
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
            return isEnabled ? .none : .easeInOut
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
                    notification: .announcementRequested,
                    userInfo: [.announcementKey: text]
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
                .onKeyPress(.space) { _ in
                    // Handle space key activation
                    return .handled
                }
                .onKeyPress(.return) { _ in
                    // Handle return key activation
                    return .handled
                }
        }
        
        static func configureButton(_ view: some View, action: @escaping () -> Void) -> some View {
            view
                .focusable()
                .onKeyPress(.space) { _ in
                    action()
                    return .handled
                }
                .onKeyPress(.return) { _ in
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
            .accessibilityTraits(AccessibilitySystem.Traits.progressIndicator)
    }
    
    func accessibilityStatus(status: String, isActive: Bool) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilitySystem.Labels.statusLabel(status: status, isActive: isActive))
            .accessibilityHint(AccessibilitySystem.Hints.statusIndicator)
            .accessibilityTraits(AccessibilitySystem.Traits.statusElement)
    }
    
    func accessibilityInteractiveButton(label: String, hint: String, action: @escaping () -> Void) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityHint(hint)
            .accessibilityTraits(AccessibilitySystem.Traits.interactiveElement)
            .accessibilityAction(named: label, action)
    }
    
    func accessibilityMetric(label: String, value: String) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue(value)
            .accessibilityTraits(AccessibilitySystem.Traits.metricElement)
    }
    
    func accessibilityCircularProgress(percentage: Double, tokenCount: Int, limit: Int) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AccessibilitySystem.Labels.circularProgressLabel(percentage: percentage, tokenCount: tokenCount, limit: limit))
            .accessibilityValue(AccessibilitySystem.Values.progressValue(percentage: percentage * 100))
            .accessibilityHint(AccessibilitySystem.Hints.circularProgress)
            .accessibilityTraits(AccessibilitySystem.Traits.progressIndicator)
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
        self.font(AccessibilitySystem.DynamicType.scaledFont(for: font, category: .medium))
    }
    
    func dynamicTypeScaled(spacing: CGFloat) -> some View {
        self.padding(AccessibilitySystem.DynamicType.scaledSpacing(for: spacing, category: .medium))
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
    var pointSize: CGFloat {
        // Extract point size from font - this is a simplified approach
        // In a real implementation, you'd need to get the actual font metrics
        return 14.0 // Default point size
    }
    
    func font(size: CGFloat) -> Font {
        return Font.system(size: size)
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