import Foundation
import SwiftUI
import Combine
import AppKit

// MARK: - Theme Preference Enum

enum ThemePreference: String, CaseIterable, Codable {
    case auto = "auto"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var description: String {
        switch self {
        case .auto: return "Follow system theme"
        case .light: return "Always use light theme"
        case .dark: return "Always use dark theme"
        }
    }
}

// MARK: - Theme Type

enum ThemeType: String, CaseIterable {
    case light = "light"
    case dark = "dark"
}

// MARK: - App Theme Structure

struct AppTheme {
    // MARK: - Background Colors
    let background: Color
    let secondaryBackground: Color
    let tertiaryBackground: Color
    
    // MARK: - Text Colors
    let text: Color
    let secondaryText: Color
    let tertiaryText: Color
    
    // MARK: - Accent Colors
    let accent: Color
    let secondaryAccent: Color
    
    // MARK: - Status Colors
    let success: Color
    let warning: Color
    let error: Color
    let info: Color
    
    // MARK: - Border Colors
    let border: Color
    let secondaryBorder: Color
    
    // MARK: - Predefined Themes
    
    static let light = AppTheme(
        // Background Colors
        background: Color(.windowBackgroundColor),
        secondaryBackground: Color(.controlBackgroundColor),
        tertiaryBackground: Color(.underPageBackgroundColor),
        
        // Text Colors
        text: Color(.labelColor),
        secondaryText: Color(.secondaryLabelColor),
        tertiaryText: Color(.tertiaryLabelColor),
        
        // Accent Colors
        accent: Color(.controlAccentColor),
        secondaryAccent: Color(.selectedControlColor),
        
        // Status Colors
        success: Color(.systemGreen),
        warning: Color(.systemOrange),
        error: Color(.systemRed),
        info: Color(.systemBlue),
        
        // Border Colors
        border: Color(.separatorColor),
        secondaryBorder: Color(.gridColor)
    )
    
    static let dark = AppTheme(
        // Background Colors
        background: Color(.windowBackgroundColor),
        secondaryBackground: Color(.controlBackgroundColor),
        tertiaryBackground: Color(.underPageBackgroundColor),
        
        // Text Colors
        text: Color(.labelColor),
        secondaryText: Color(.secondaryLabelColor),
        tertiaryText: Color(.tertiaryLabelColor),
        
        // Accent Colors
        accent: Color(.controlAccentColor),
        secondaryAccent: Color(.selectedControlColor),
        
        // Status Colors
        success: Color(.systemGreen),
        warning: Color(.systemOrange),
        error: Color(.systemRed),
        info: Color(.systemBlue),
        
        // Border Colors
        border: Color(.separatorColor),
        secondaryBorder: Color(.gridColor)
    )
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    
    // MARK: - Shared Instance
    
    static let shared = ThemeManager()
    
    // MARK: - Published Properties
    
    @Published var userPreference: ThemePreference {
        didSet {
            savePreference()
            updateEffectiveTheme()
        }
    }
    
    @Published var effectiveTheme: ThemeType {
        didSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let preferenceKey = "themePreference"
    private var systemThemeObserver: AnyCancellable?
    
    // MARK: - Computed Properties
    
    var systemTheme: ThemeType {
        let appearance = NSApplication.shared.effectiveAppearance
        let bestMatch = appearance.bestMatch(from: [.aqua, .darkAqua])
        return bestMatch == .darkAqua ? .dark : .light
    }
    
    var currentTheme: AppTheme {
        switch effectiveTheme {
        case .light: return AppTheme.light
        case .dark: return AppTheme.dark
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Load saved preference or default to auto
        let savedPreference: ThemePreference
        if let storedPreference = userDefaults.string(forKey: preferenceKey),
           let preference = ThemePreference(rawValue: storedPreference) {
            savedPreference = preference
        } else {
            savedPreference = .auto
        }
        
        self.userPreference = savedPreference
        
        // Initialize effective theme based on preference
        switch savedPreference {
        case .auto:
            self.effectiveTheme = NSApplication.shared.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? .dark : .light
        case .light:
            self.effectiveTheme = .light
        case .dark:
            self.effectiveTheme = .dark
        }
        
        // Observe system theme changes
        setupSystemThemeObserver()
    }
    
    // MARK: - Public Methods
    
    func toggleTheme() {
        switch userPreference {
        case .auto, .light:
            userPreference = .dark
        case .dark:
            userPreference = .light
        }
    }
    
    func handleSystemThemeChange() {
        if userPreference == .auto {
            updateEffectiveTheme()
        }
    }
    
    // MARK: - Private Methods
    
    private func savePreference() {
        userDefaults.set(userPreference.rawValue, forKey: preferenceKey)
    }
    
    private func updateEffectiveTheme() {
        switch userPreference {
        case .auto:
            effectiveTheme = systemTheme
        case .light:
            effectiveTheme = .light
        case .dark:
            effectiveTheme = .dark
        }
    }
    
    private func setupSystemThemeObserver() {
        // Use distributed notification for system appearance changes (more efficient than polling)
        systemThemeObserver = DistributedNotificationCenter.default()
            .publisher(for: .init("AppleInterfaceThemeChangedNotification"))
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.userPreference == .auto {
                    let newSystemTheme = self.systemTheme
                    if newSystemTheme != self.effectiveTheme {
                        self.effectiveTheme = newSystemTheme
                    }
                }
            }
    }
}

// MARK: - Theme Environment

struct ThemeEnvironment: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeEnvironment.self] }
        set { self[ThemeEnvironment.self] = newValue }
    }
}

// MARK: - Theme Modifier

struct ThemedModifier: ViewModifier {
    @EnvironmentObject private var themeManager: ThemeManager
    
    func body(content: Content) -> some View {
        content
            .background(themeManager.currentTheme.background)
            .foregroundColor(themeManager.currentTheme.text)
            .preferredColorScheme(themeManager.effectiveTheme == .dark ? .dark : .light)
    }
}

extension View {
    func themed() -> some View {
        self.modifier(ThemedModifier())
    }
}

// MARK: - Theme-Aware Colors

extension Color {
    static func themed(_ light: Color, _ dark: Color) -> Color {
        return Color(NSColor.controlAccentColor) // Placeholder - will be replaced by theme-aware implementation
    }
}

// MARK: - Theme Utilities

extension AppTheme {
    
    // MARK: - Semantic Color Mappings
    
    var tokenCountColor: Color {
        return text
    }
    
    var sessionStatusColor: Color {
        return secondaryText
    }
    
    var burnRateColor: Color {
        return accent
    }
    
    var progressBarBackground: Color {
        return secondaryBackground
    }
    
    var progressBarForeground: Color {
        return accent
    }
    
    var cardBackground: Color {
        return secondaryBackground
    }
    
    var cardBorder: Color {
        return border
    }
    
    // MARK: - Status-Based Colors
    
    func statusColor(for progress: Double) -> Color {
        if progress >= 0.85 {
            return error
        } else if progress >= 0.60 {
            return warning
        } else if progress >= 0.30 {
            return info
        } else {
            return success
        }
    }
    
    func burnRateColor(for burnRate: Double) -> Color {
        if burnRate > 100.0 {
            return error
        } else if burnRate > 50.0 {
            return warning
        } else {
            return success
        }
    }
}