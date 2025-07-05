import SwiftUI

// MARK: - Shimmer Effect Components

struct ShimmerView: View {
    @State private var startPoint = UnitPoint(x: -1, y: 0)
    @State private var endPoint = UnitPoint(x: 0, y: 0)
    
    let baseColor: Color
    let highlightColor: Color
    let animationDuration: Double
    
    init(
        baseColor: Color = Color.gray.opacity(0.3),
        highlightColor: Color = Color.white.opacity(0.6),
        animationDuration: Double = 1.5
    ) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.animationDuration = animationDuration
    }
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [baseColor, highlightColor, baseColor]),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
            .onAppear {
                guard !AccessibilitySystem.ReducedMotion.isEnabled else { return }
                
                withAnimation(
                    .linear(duration: animationDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    startPoint = UnitPoint(x: 1, y: 0)
                    endPoint = UnitPoint(x: 2, y: 0)
                }
            }
    }
}

// MARK: - Shimmer Text Loading

struct ShimmerText: View {
    let width: CGFloat
    let height: CGFloat
    
    init(width: CGFloat = 100, height: CGFloat = 12) {
        self.width = width
        self.height = height
    }
    
    var body: some View {
        ShimmerView()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }
}

// MARK: - Shimmer Progress Bar

struct ShimmerProgressBar: View {
    let height: CGFloat
    
    init(height: CGFloat = DesignTokens.Layout.progressBarHeight) {
        self.height = height
    }
    
    var body: some View {
        HStack(spacing: .spacingSm) {
            // Model name placeholder
            ShimmerText(width: 60, height: 12)
            
            Spacer()
            
            // Percentage placeholder
            ShimmerText(width: 30, height: 12)
        }
        .padding(.vertical, .spacingXs)
        
        // Progress bar placeholder
        ShimmerView()
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }
}

// MARK: - Shimmer Session Card

struct ShimmerSessionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingMd) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: .spacingXs) {
                    ShimmerText(width: 120, height: 16)  // "Current Session"
                    ShimmerText(width: 140, height: 24)  // Token count
                    ShimmerText(width: 80, height: 14)   // Status
                }
                
                Spacer()
                
                // Circular progress placeholder
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: .progressCircleSize, height: .progressCircleSize)
                    .overlay(
                        ShimmerView()
                            .clipShape(Circle())
                    )
            }
            
            // Metrics
            VStack(spacing: .spacing2) {
                // Usage Metrics Group
                VStack(alignment: .leading, spacing: .spacing1) {
                    ShimmerText(width: 90, height: 12)  // "Current Usage"
                    
                    HStack(spacing: .spacing2) {
                        ShimmerMetricCard()
                        ShimmerMetricCard()
                    }
                }
                
                // Time Data Group
                VStack(alignment: .leading, spacing: .spacing1) {
                    ShimmerText(width: 70, height: 12)  // "Time Data"
                    
                    HStack(spacing: .spacing2) {
                        ShimmerMetricCard()
                        ShimmerMetricCard()
                    }
                }
            }
            
            // Model Usage
            VStack(alignment: .leading, spacing: .spacingSm) {
                ShimmerText(width: 90, height: 14)  // "Model Usage"
                
                VStack(spacing: .spacingXs) {
                    ShimmerProgressBar()
                    ShimmerProgressBar()
                    ShimmerProgressBar()
                }
            }
        }
        .padding(.spacingLg)
        .background(Color.backgroundSecondary)
        .cornerRadius(.cardRadius)
    }
}

// MARK: - Shimmer Metric Card

struct ShimmerMetricCard: View {
    var body: some View {
        HStack(spacing: .spacing2) {
            // Icon placeholder
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: .iconFrameSize, height: .iconFrameSize)
            
            VStack(alignment: .leading, spacing: 1) {
                ShimmerText(width: 40, height: 10)  // Label
                ShimmerText(width: 50, height: 12)  // Value
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, .spacing2)
        .padding(.vertical, .spacing1)
        .background(Color.backgroundSecondary)
        .cornerRadius(.cornerRadiusMedium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Shimmer Footer

struct ShimmerFooter: View {
    var body: some View {
        HStack(spacing: .spacingSm) {
            // Status indicator
            HStack(spacing: .spacingXs) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                
                ShimmerText(width: 60, height: 12)  // "Loading..."
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: .spacingSm) {
                ShimmerText(width: 35, height: 12)  // "Retry" 
                ShimmerText(width: 30, height: 12)  // "Quit"
            }
        }
        .padding(.horizontal, .spacingLg)
        .padding(.vertical, .spacingMd)
        .background(Color.backgroundSecondary)
        .cornerRadius(.radiusSm)
    }
}

// MARK: - Loading State Container

struct LoadingStateView: View {
    let showFullInterface: Bool
    
    init(showFullInterface: Bool = true) {
        self.showFullInterface = showFullInterface
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if showFullInterface {
                // Header shimmer
                HStack {
                    VStack(alignment: .leading, spacing: .spacingXs) {
                        ShimmerText(width: 100, height: 16)  // "Claude Radar"
                        ShimmerText(width: 130, height: 12)  // "Token Usage Monitor"
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
                .padding(.spacingLg)
                
                Divider().opacity(0.3)
                
                // Main content shimmer
                ShimmerSessionCard()
                
                Divider().opacity(0.5)
                
                // Chart section shimmer
                VStack(alignment: .leading, spacing: .spacing1) {
                    HStack {
                        ShimmerText(width: 100, height: 12)  // "Active Sessions"
                        Spacer()
                        ShimmerText(width: 60, height: 10)   // "0 active"
                    }
                    
                    VStack(spacing: .spacing1) {
                        ForEach(0..<2, id: \.self) { _ in
                            HStack(spacing: .spacing2) {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 6, height: 6)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack {
                                        ShimmerText(width: 80, height: 10)
                                        Spacer()
                                        ShimmerText(width: 30, height: 10)
                                    }
                                    
                                    ShimmerView()
                                        .frame(height: 2)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(.spacing2)
                
                Divider().opacity(0.5)
                
                // Quick actions and footer
                VStack(spacing: .spacingSm) {
                    HStack {
                        ShimmerText(width: 50, height: 12)  // "Export"
                        Spacer()
                        ShimmerText(width: 55, height: 12)  // "Settings"
                    }
                    .padding(.horizontal, .spacing3)
                    .padding(.top, .spacing2)
                    
                    ShimmerFooter()
                }
            } else {
                // Compact loading view
                VStack(spacing: .spacingLg) {
                    ShimmerText(width: 120, height: 16)
                    ShimmerText(width: 80, height: 14)
                    
                    VStack(spacing: .spacingXs) {
                        ShimmerProgressBar()
                        ShimmerProgressBar()
                    }
                }
                .padding(.spacingLg)
            }
        }
        .background(Color.backgroundPrimary)
    }
}

// MARK: - SwiftUI Extension for Shimmer

extension View {
    func shimmerEffect(isLoading: Bool) -> some View {
        Group {
            if isLoading && !AccessibilitySystem.ReducedMotion.isEnabled {
                self.redacted(reason: .placeholder)
                    .overlay(
                        ShimmerView(
                            baseColor: Color.clear,
                            highlightColor: Color.white.opacity(0.3)
                        )
                        .allowsHitTesting(false)
                    )
            } else {
                self
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ShimmerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingStateView(showFullInterface: true)
                .frame(width: DesignTokens.Layout.menuBarWidth)
                .previewDisplayName("Full Loading State")
            
            LoadingStateView(showFullInterface: false)
                .frame(width: DesignTokens.Layout.menuBarWidth)
                .previewDisplayName("Compact Loading State")
            
            VStack(spacing: .spacingLg) {
                ShimmerSessionCard()
                ShimmerFooter()
            }
            .padding()
            .background(Color.backgroundPrimary)
            .previewDisplayName("Individual Components")
        }
    }
}
#endif