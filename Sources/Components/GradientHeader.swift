import SwiftUI

// MARK: - Gradient Header Configuration

struct GradientHeader: View {
    let configuration: Configuration
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isVisible = false
    
    struct Configuration {
        let title: String
        let subtitle: String
        let showsLocation: Bool
        let showsRefreshButton: Bool
        
        static let `default` = Configuration(
            title: "Claude Radar",
            subtitle: "Token Usage Monitor",
            showsLocation: true,
            showsRefreshButton: true
        )
    }
    
    var body: some View {
        ZStack {
            // Gradient background
            HeaderGradient.themeAware(for: themeManager.effectiveTheme)
                .background
            
            // Content overlay
            HStack(spacing: .spacingMd) {
                // Left content: Icon + Text
                HStack(spacing: .spacingMd) {
                    // App icon with modern styling
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "gauge.high")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: .spacingXs) {
                        Text(configuration.title)
                            .font(.semanticAppTitle)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        
                        Text(configuration.subtitle)
                            .font(.appSubtitle)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Right content: Location + Refresh
                HStack(spacing: .spacingMd) {
                    if configuration.showsLocation {
                        HeaderLocationBadge()
                    }
                    
                    if configuration.showsRefreshButton {
                        HeaderRefreshButton(
                            configuration: .default,
                            action: {
                                // Refresh action will be passed from parent
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, .spacingLg)
            .padding(.vertical, .spacingMd)
        }
        .frame(height: HeaderLayout.standard.height)
        .cornerRadius(.cardRadius)
        .opacity(isVisible ? 1.0 : 0.0)
        .scaleEffect(isVisible ? 1.0 : 0.95)
        .onAppear {
            withAnimation(.easeOut(duration: DesignTokens.Animation.normal)) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Gradient Colors
    
    static func gradientColors(for theme: ThemeType) -> [Color] {
        switch theme {
        case .light:
            return [
                Color(red: 0.2, green: 0.6, blue: 1.0),  // Bright blue
                Color(red: 0.4, green: 0.3, blue: 0.9)   // Purple
            ]
        case .dark:
            return [
                Color(red: 0.1, green: 0.3, blue: 0.6),  // Dark blue
                Color(red: 0.2, green: 0.1, blue: 0.4)   // Dark purple
            ]
        }
    }
}

// MARK: - Header Location Badge

struct HeaderLocationBadge: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: .spacingXs) {
            Image(systemName: "location.fill")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Text(locationText)
                .font(.semanticFootnote)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
        .padding(.horizontal, .spacingSm)
        .padding(.vertical, .spacingXs)
        .background(Color.white.opacity(0.15))
        .cornerRadius(.radiusSm)
    }
    
    private var locationText: String {
        let timeZone = TimeZone.preferred
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.timeStyle = .short
        
        return timeZone.localizedName(for: .standard, locale: .current) ?? "Local"
    }
}

// MARK: - Header Refresh Button

struct HeaderRefreshButton: View {
    let configuration: Configuration
    let action: () -> Void
    @State private var isRotating = false
    
    struct Configuration {
        let isLoading: Bool
        let isEnabled: Bool
        
        static let `default` = Configuration(
            isLoading: false,
            isEnabled: true
        )
    }
    
    var body: some View {
        Button(action: {
            if configuration.isEnabled && !configuration.isLoading {
                action()
                withAnimation(.linear(duration: 0.5).repeatCount(2, autoreverses: false)) {
                    isRotating.toggle()
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                if configuration.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!configuration.isEnabled || configuration.isLoading)
        .accessibilityLabel("Refresh data")
        .accessibilityHint("Refreshes token usage data")
    }
}

// MARK: - Header Gradient System

struct HeaderGradient {
    let configuration: Configuration
    
    struct Configuration {
        let colors: [Color]
        let direction: UnitPoint
        let opacity: Double
        
        static let lightDefault = Configuration(
            colors: GradientHeader.gradientColors(for: .light),
            direction: .topLeading,
            opacity: 1.0
        )
        
        static let darkDefault = Configuration(
            colors: GradientHeader.gradientColors(for: .dark),
            direction: .topLeading,
            opacity: 1.0
        )
    }
    
    var background: some View {
        LinearGradient(
            colors: configuration.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(configuration.opacity)
    }
    
    static func themeAware(for theme: ThemeType) -> HeaderGradient {
        switch theme {
        case .light:
            return HeaderGradient(configuration: .lightDefault)
        case .dark:
            return HeaderGradient(configuration: .darkDefault)
        }
    }
}

// MARK: - Header Layout System

struct HeaderLayout {
    let height: CGFloat
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let cornerRadius: CGFloat
    
    static let standard = HeaderLayout(
        height: 80,
        paddingHorizontal: DesignTokens.Spacing.lg,
        paddingVertical: DesignTokens.Spacing.md,
        cornerRadius: DesignTokens.BorderRadius.lg
    )
    
    static let compact = HeaderLayout(
        height: 60,
        paddingHorizontal: DesignTokens.Spacing.md,
        paddingVertical: DesignTokens.Spacing.sm,
        cornerRadius: DesignTokens.BorderRadius.md
    )
}

// MARK: - Header Status Display

struct HeaderStatus: View {
    let session: ClaudeSession?
    
    var body: some View {
        HStack(spacing: .spacingXs) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.semanticFootnote)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, .spacingSm)
        .padding(.vertical, .spacingXs)
        .background(Color.white.opacity(0.1))
        .cornerRadius(.radiusSm)
    }
    
    var statusText: String {
        guard let session = session else { return "No Session" }
        return session.isActive ? "Active Session" : "Session Ended"
    }
    
    var statusColor: Color {
        guard let session = session else { return .gray }
        return session.isActive ? .green : .orange
    }
    
    var progressPercentage: Double {
        return session?.progress ?? 0.0
    }
}

// MARK: - Header Location Display

struct HeaderLocationDisplay: View {
    let timeZone: TimeZone
    let session: ClaudeSession?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: .spacingXs) {
            Text(timeZoneDisplay)
                .font(.semanticFootnote)
                .foregroundColor(.white.opacity(0.8))
            
            if let endTime = sessionEndTime {
                Text("Ends \(endTime)")
                    .font(.semanticFootnote)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    var timeZoneDisplay: String {
        return timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier
    }
    
    var sessionEndTime: String? {
        guard let session = session, session.isActive else { return nil }
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.timeStyle = .short
        return formatter.string(from: session.endTime)
    }
}

// MARK: - Header Title Components

struct HeaderTitle: View {
    let configuration: Configuration
    
    struct Configuration {
        let text: String
        let style: Style
        let showsIcon: Bool
        
        enum Style {
            case primary
            case secondary
        }
    }
    
    var body: some View {
        HStack(spacing: .spacingSm) {
            if configuration.showsIcon {
                Image(systemName: "gauge.high")
                    .font(.title3)
                    .foregroundColor(.white)
            }
            
            Text(configuration.text)
                .font(configuration.style == .primary ? .semanticAppTitle : .appSubtitle)
                .foregroundColor(.white)
                .fontWeight(configuration.style == .primary ? .bold : .medium)
        }
    }
}

struct HeaderSubtitle: View {
    let configuration: Configuration
    
    struct Configuration {
        let text: String
        let style: Style
        
        enum Style {
            case secondary
            case tertiary
        }
    }
    
    var body: some View {
        Text(configuration.text)
            .font(.appSubtitle)
            .foregroundColor(.white.opacity(configuration.style == .secondary ? 0.8 : 0.6))
    }
}

// MARK: - Header Animation System

struct HeaderAnimation {
    let configuration: Configuration
    
    struct Configuration {
        let entrance: EntranceStyle
        let duration: Double
        let delay: Double
        
        enum EntranceStyle {
            case slideFromTop
            case fadeIn
            case scaleUp
        }
    }
}

// MARK: - Accessible Header

struct AccessibleGradientHeader: View {
    let configuration: GradientHeader.Configuration
    let session: ClaudeSession?
    
    var body: some View {
        GradientHeader(configuration: configuration)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue)
    }
    
    var accessibilityLabel: String {
        return "\(configuration.title), \(configuration.subtitle)"
    }
    
    var accessibilityValue: String {
        guard let session = session else { return "No active session" }
        let percentage = Int((session.progress * 100).rounded())
        return "Session \(percentage)% used, \(session.isActive ? "active" : "ended")"
    }
}

// MARK: - Complete Header Integration

struct CompleteGradientHeader: View {
    let session: ClaudeSession?
    let themeManager: ThemeManager
    let onRefresh: () -> Void
    
    var body: some View {
        ZStack {
            // Gradient background
            HeaderGradient.themeAware(for: themeManager.effectiveTheme)
                .background
            
            // Content
            HStack {
                // Left: App branding
                HStack(spacing: .spacingMd) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "gauge.high")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: .spacingXs) {
                        Text("Claude Radar")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Text("Usage Monitor")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Right: Status and actions (more compact)
                HStack(spacing: .spacingSm) {
                    if let session = session {
                        HeaderStatus(session: session)
                    }
                    
                    HeaderRefreshButton(
                        configuration: .default,
                        action: onRefresh
                    )
                }
            }
            .padding(.horizontal, .spacingLg)
            .padding(.vertical, .spacingMd)
        }
        .frame(height: HeaderLayout.standard.height)
        .cornerRadius(.cardRadius)
    }
}

// MARK: - View Extensions

extension View {
    func headerStyle() -> some View {
        self
            .cornerRadius(.cardRadius)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}