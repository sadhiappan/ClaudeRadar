import SwiftUI

// MARK: - Model Progress Bar

struct ModelProgressBar: View {
    let breakdown: ModelUsageBreakdown
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingSm) {
            // Model info header
            HStack {
                // Model indicator dot
                Circle()
                    .fill(breakdown.modelInfo.color)
                    .frame(width: .spacingSm, height: .spacingSm)
                
                Text(breakdown.modelInfo.shortName)
                    .font(.semanticMetricLabel)
                    .dynamicTypeScaled(font: .semanticMetricLabel)
                    .highContrastAdjusted(color: .primary)
                
                Spacer()
                
                // Percentage
                Text(formattedPercentage)
                    .font(.semanticMetricValue)
                    .dynamicTypeScaled(font: .semanticMetricValue)
                    .highContrastAdjusted(color: .primary)
                    .monospacedDigit()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: DesignTokens.Layout.progressBarHeight)
                        .cornerRadius(.progressBarRadius)
                    
                    // Progress fill
                    Rectangle()
                        .fill(breakdown.modelInfo.color)
                        .frame(
                            width: geometry.size.width * animatedProgress,
                            height: DesignTokens.Layout.progressBarHeight
                        )
                        .cornerRadius(.progressBarRadius)
                        .reducedMotionAnimation(duration: DesignTokens.Animation.normal)
                }
            }
            .frame(height: DesignTokens.Layout.progressBarHeight)
            
            // Token count
            Text("\(breakdown.tokenCount) tokens")
                .font(.semanticCaption)
                .dynamicTypeScaled(font: .semanticCaption)
                .highContrastAdjusted(color: .secondary)
                .accessibilityLabel("Token count: \(breakdown.tokenCount)")
        }
        .accessibilityProgress(
            model: breakdown.modelInfo.shortName,
            percentage: breakdown.percentage,
            tokenCount: breakdown.tokenCount
        )
        .keyboardFocusable()
        .reducedMotionAnimation(duration: DesignTokens.Animation.normal)
        .onAppear {
            // Only animate once on first appearance
            if animatedProgress == 0.0 {
                withAnimation(.easeInOut(duration: DesignTokens.Animation.normal).delay(0.1)) {
                    animatedProgress = breakdown.percentage / 100.0
                }
            }
        }
        .onChange(of: breakdown.percentage) { _, newPercentage in
            // Update without animation on data changes
            animatedProgress = newPercentage / 100.0
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedPercentage: String {
        return "\(Int(breakdown.percentage.rounded()))%"
    }
    
    var accessibilityLabel: String {
        return AccessibilitySystem.Labels.modelProgressLabel(
            modelInfo: breakdown.modelInfo,
            tokenCount: breakdown.tokenCount,
            percentage: breakdown.percentage
        )
    }
    
    var accessibilityValue: String {
        return AccessibilitySystem.Values.tokenValue(
            count: breakdown.tokenCount,
            limit: Int(Double(breakdown.tokenCount) / (breakdown.percentage / 100.0))
        )
    }
    
    // MARK: - View Model
    
    struct ViewModel {
        let breakdown: ModelUsageBreakdown
        
        var modelName: String {
            breakdown.modelInfo.shortName
        }
        
        var tokenCount: Int {
            breakdown.tokenCount
        }
        
        var percentage: Double {
            breakdown.percentage
        }
        
        var formattedTokens: String {
            "\(tokenCount)"
        }
        
        var formattedPercentage: String {
            "\(Int(percentage.rounded()))%"
        }
        
        var modelColor: Color {
            breakdown.modelInfo.color
        }
    }
}

// MARK: - Compact Model Progress Bar

struct CompactModelProgressBar: View {
    let breakdown: ModelUsageBreakdown
    let isCompact: Bool = true
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        HStack(spacing: .spacingSm) {
            // Model indicator
            Circle()
                .fill(breakdown.modelInfo.color)
                .frame(width: 8, height: 8)
            
            Text(breakdown.modelInfo.shortName)
                .font(.semanticFootnote)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(minWidth: 50, alignment: .leading)
            
            // Mini progress bar with flexible width
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(breakdown.modelInfo.color)
                        .frame(
                            width: geometry.size.width * animatedProgress,
                            height: 4
                        )
                        .cornerRadius(2)
                        .animation(
                            .easeInOut(duration: DesignTokens.Animation.fast),
                            value: animatedProgress
                        )
                }
            }
            .frame(height: 4)
            
            Text(formattedPercentage)
                .font(.semanticFootnote)
                .foregroundColor(.secondary)
                .monospacedDigit()
                .frame(minWidth: 35, alignment: .trailing)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.fast).delay(0.05)) {
                animatedProgress = breakdown.percentage / 100.0
            }
        }
    }
    
    private var formattedPercentage: String {
        return "\(Int(breakdown.percentage.rounded()))%"
    }
}

// MARK: - Detailed Model Progress Bar

struct DetailedModelProgressBar: View {
    let breakdown: ModelUsageBreakdown
    let isCompact: Bool = false
    let showsTokenCount: Bool = true
    let showsPercentage: Bool = true
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingMd) {
            // Header with model info
            HStack {
                VStack(alignment: .leading, spacing: .spacingXs) {
                    HStack(spacing: .spacingSm) {
                        Circle()
                            .fill(breakdown.modelInfo.color)
                            .frame(width: .spacingMd, height: .spacingMd)
                        
                        Text(breakdown.modelInfo.displayName)
                            .font(.semanticMetricLabel)
                            .foregroundColor(.primary)
                        
                        if breakdown.modelInfo.isHighPerformance {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    if showsTokenCount {
                        Text("\(breakdown.tokenCount) tokens")
                            .font(.semanticCaption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if showsPercentage {
                    VStack(alignment: .trailing, spacing: .spacingXs) {
                        Text(formattedPercentage)
                            .font(.semanticMetricValue)
                            .foregroundColor(.primary)
                            .monospacedDigit()
                        
                        Text("of session")
                            .font(.semanticFootnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress bar with enhanced styling
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background with border
                    RoundedRectangle(cornerRadius: .progressBarRadius)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: .progressBarRadius)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .frame(height: 12)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: .progressBarRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    breakdown.modelInfo.color.opacity(0.8),
                                    breakdown.modelInfo.color
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * animatedProgress,
                            height: 12
                        )
                        .animation(
                            .easeInOut(duration: DesignTokens.Animation.normal),
                            value: animatedProgress
                        )
                }
            }
            .frame(height: 12)
        }
        .componentPadding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(.cardRadius)
        .onAppear {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.normal).delay(0.2)) {
                animatedProgress = breakdown.percentage / 100.0
            }
        }
    }
    
    private var formattedPercentage: String {
        return "\(Int(breakdown.percentage.rounded()))%"
    }
}

// MARK: - Animated Progress Bar

struct AnimatedProgressBar: View {
    let targetProgress: Double
    let color: Color
    let backgroundColor: Color
    let animationDuration: Double = DesignTokens.Animation.normal
    
    @State private var currentProgress: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .fill(backgroundColor)
                    .cornerRadius(.progressBarRadius)
                
                // Progress
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * currentProgress)
                    .cornerRadius(.progressBarRadius)
                    .animation(
                        .easeInOut(duration: animationDuration),
                        value: currentProgress
                    )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration)) {
                currentProgress = targetProgress
            }
        }
        .onChange(of: targetProgress) { _, newValue in
            withAnimation(.easeInOut(duration: animationDuration)) {
                currentProgress = newValue
            }
        }
    }
}

// MARK: - Circular Progress Indicator

struct CircularProgressIndicator: View {
    let session: ClaudeSession
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(
                    .easeInOut(duration: DesignTokens.Animation.slow),
                    value: animatedProgress
                )
            
            // Center content
            VStack(spacing: .spacingXs) {
                Text("\(Int((animatedProgress * 100).rounded()))%")
                    .font(.semanticMetricValue)
                    .foregroundColor(.primary)
                    .monospacedDigit()
                
                Text("used")
                    .font(.semanticFootnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: DesignTokens.Layout.circularProgressSize, 
               height: DesignTokens.Layout.circularProgressSize)
        .onAppear {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.slow).delay(0.3)) {
                animatedProgress = progressValue
            }
        }
    }
    
    var progressValue: Double {
        return session.progress
    }
    
    var progressColor: Color {
        let progress = progressValue
        if progress >= 0.85 {
            return .red
        } else if progress >= 0.60 {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - Progress Animation System

struct ProgressBarAnimation {
    let duration: Double
    let delay: Double
    let easeInOut: Bool
    
    static let standard = ProgressBarAnimation(
        duration: DesignTokens.Animation.normal,
        delay: 0.0,
        easeInOut: true
    )
    
    static let fast = ProgressBarAnimation(
        duration: DesignTokens.Animation.fast,
        delay: 0.0,
        easeInOut: true
    )
    
    static let slow = ProgressBarAnimation(
        duration: DesignTokens.Animation.slow,
        delay: 0.0,
        easeInOut: true
    )
}

struct StaggeredProgressAnimation {
    let breakdowns: [ModelUsageBreakdown]
    let baseDelay: Double = 0.1
    
    var delays: [Double] {
        return breakdowns.enumerated().map { index, _ in
            Double(index) * baseDelay
        }
    }
}

// MARK: - Progress Bar Collection

struct ModelProgressCollection: View {
    let breakdowns: [ModelUsageBreakdown]
    let style: Style
    
    enum Style {
        case compact
        case detailed
        case standard
    }
    
    var body: some View {
        LazyVStack(spacing: .spacingSm) {
            ForEach(Array(filteredBreakdowns.enumerated()), id: \.element.id) { index, breakdown in
                Group {
                    switch style {
                    case .compact:
                        CompactModelProgressBar(breakdown: breakdown)
                    case .detailed:
                        DetailedModelProgressBar(breakdown: breakdown)
                    case .standard:
                        ModelProgressBar(breakdown: breakdown)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
    }
    
    // Filter out models with 0% usage
    private var filteredBreakdowns: [ModelUsageBreakdown] {
        return breakdowns.filter { $0.percentage > 0.1 } // Only show models with > 0.1% usage
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension ModelProgressBar {
    static var previewData: [ModelUsageBreakdown] {
        [
            ModelUsageBreakdown(modelType: .opus, tokenCount: 1500, percentage: 60.0),
            ModelUsageBreakdown(modelType: .sonnet, tokenCount: 750, percentage: 30.0),
            ModelUsageBreakdown(modelType: .haiku, tokenCount: 250, percentage: 10.0)
        ]
    }
}
#endif