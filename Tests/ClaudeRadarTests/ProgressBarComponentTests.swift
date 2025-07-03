import XCTest
import SwiftUI
@testable import ClaudeRadar

class ProgressBarComponentTests: XCTestCase {
    
    // MARK: - Model Progress Bar Tests
    
    func testModelProgressBarCreation() {
        // Given - Model usage data
        let modelBreakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 1500,
            percentage: 75.0
        )
        
        // When - Creating progress bar
        let progressBar = ModelProgressBar(breakdown: modelBreakdown)
        
        // Then - Should initialize correctly
        XCTAssertNotNil(progressBar)
        XCTAssertEqual(progressBar.breakdown.modelType, .opus)
        XCTAssertEqual(progressBar.breakdown.percentage, 75.0)
    }
    
    func testModelProgressBarViewModel() {
        // Given - Model breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .sonnet,
            tokenCount: 800,
            percentage: 40.0
        )
        
        // When - Creating view model
        let viewModel = ModelProgressBar.ViewModel(breakdown: breakdown)
        
        // Then - Should provide correct data
        XCTAssertEqual(viewModel.modelName, "Sonnet")
        XCTAssertEqual(viewModel.tokenCount, 800)
        XCTAssertEqual(viewModel.percentage, 40.0)
        XCTAssertEqual(viewModel.formattedTokens, "800")
        XCTAssertEqual(viewModel.formattedPercentage, "40%")
        XCTAssertNotNil(viewModel.modelColor)
    }
    
    func testProgressBarAccessibility() {
        // Given - Model breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .haiku,
            tokenCount: 250,
            percentage: 12.5
        )
        
        // When - Creating progress bar
        let progressBar = ModelProgressBar(breakdown: breakdown)
        
        // Then - Should have accessibility support
        XCTAssertNotNil(progressBar.accessibilityLabel)
        XCTAssertNotNil(progressBar.accessibilityValue)
        XCTAssertTrue(progressBar.accessibilityLabel.contains("Haiku"))
        XCTAssertTrue(progressBar.accessibilityValue.contains("12%"))
    }
    
    // MARK: - Animated Progress Bar Tests
    
    func testAnimatedProgressBar() {
        // Given - Progress value
        let progress: Double = 0.6
        
        // When - Creating animated progress bar
        let progressBar = AnimatedProgressBar(
            progress: progress,
            color: .blue,
            backgroundColor: .gray.opacity(0.2)
        )
        
        // Then - Should initialize with correct values
        XCTAssertNotNil(progressBar)
        XCTAssertEqual(progressBar.targetProgress, 0.6)
    }
    
    func testProgressBarAnimation() {
        // Given - Animated progress bar
        let progressBar = AnimatedProgressBar(
            progress: 0.8,
            color: .green,
            backgroundColor: .gray.opacity(0.1)
        )
        
        // When - Animation should be configured
        // Then - Should use appropriate animation duration
        XCTAssertEqual(progressBar.animationDuration, DesignTokens.Animation.normal)
    }
    
    // MARK: - Circular Progress Tests
    
    func testCircularProgress() {
        // Given - Session data
        let session = createMockSession(tokenCount: 2500, tokenLimit: 10000)
        
        // When - Creating circular progress
        let circularProgress = CircularProgressIndicator(session: session)
        
        // Then - Should calculate correct progress
        XCTAssertNotNil(circularProgress)
        XCTAssertEqual(circularProgress.progressValue, 0.25, accuracy: 0.01)
    }
    
    func testCircularProgressColors() {
        // Given - Different progress levels
        let lowProgressSession = createMockSession(tokenCount: 1000, tokenLimit: 10000) // 10%
        let mediumProgressSession = createMockSession(tokenCount: 6000, tokenLimit: 10000) // 60%
        let highProgressSession = createMockSession(tokenCount: 9000, tokenLimit: 10000) // 90%
        
        // When - Creating circular progress indicators
        let lowProgress = CircularProgressIndicator(session: lowProgressSession)
        let mediumProgress = CircularProgressIndicator(session: mediumProgressSession)
        let highProgress = CircularProgressIndicator(session: highProgressSession)
        
        // Then - Should use appropriate colors
        XCTAssertEqual(lowProgress.progressColor, .systemGreen)
        XCTAssertEqual(mediumProgress.progressColor, .systemOrange)
        XCTAssertEqual(highProgress.progressColor, .systemRed)
    }
    
    // MARK: - Progress Bar Variants Tests
    
    func testCompactProgressBar() {
        // Given - Model breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 3000,
            percentage: 60.0
        )
        
        // When - Creating compact progress bar
        let compactBar = CompactModelProgressBar(breakdown: breakdown)
        
        // Then - Should have compact layout
        XCTAssertNotNil(compactBar)
        XCTAssertEqual(compactBar.breakdown.modelType, .opus)
        XCTAssertTrue(compactBar.isCompact)
    }
    
    func testDetailedProgressBar() {
        // Given - Model breakdown
        let breakdown = ModelUsageBreakdown(
            modelType: .sonnet,
            tokenCount: 1200,
            percentage: 24.0
        )
        
        // When - Creating detailed progress bar
        let detailedBar = DetailedModelProgressBar(breakdown: breakdown)
        
        // Then - Should have detailed layout
        XCTAssertNotNil(detailedBar)
        XCTAssertEqual(detailedBar.breakdown.modelType, .sonnet)
        XCTAssertFalse(detailedBar.isCompact)
        XCTAssertTrue(detailedBar.showsTokenCount)
        XCTAssertTrue(detailedBar.showsPercentage)
    }
    
    // MARK: - Progress Animation Tests
    
    func testProgressAnimationTiming() {
        // Given - Animation configuration
        let animation = ProgressBarAnimation.standard
        
        // Then - Should use design token durations
        XCTAssertEqual(animation.duration, DesignTokens.Animation.normal)
        XCTAssertEqual(animation.delay, 0.0)
        XCTAssertTrue(animation.easeInOut)
    }
    
    func testStaggeredAnimation() {
        // Given - Multiple progress bars
        let breakdowns = [
            ModelUsageBreakdown(modelType: .opus, tokenCount: 1500, percentage: 50.0),
            ModelUsageBreakdown(modelType: .sonnet, tokenCount: 900, percentage: 30.0),
            ModelUsageBreakdown(modelType: .haiku, tokenCount: 600, percentage: 20.0)
        ]
        
        // When - Creating staggered animation
        let staggeredAnimation = StaggeredProgressAnimation(breakdowns: breakdowns)
        
        // Then - Should stagger animation timing
        XCTAssertEqual(staggeredAnimation.delays.count, 3)
        XCTAssertEqual(staggeredAnimation.delays[0], 0.0)
        XCTAssertEqual(staggeredAnimation.delays[1], 0.1, accuracy: 0.01)
        XCTAssertEqual(staggeredAnimation.delays[2], 0.2, accuracy: 0.01)
    }
    
    // MARK: - Accessibility Tests
    
    func testProgressBarAccessibilityTraits() {
        // Given - Model progress bar
        let breakdown = ModelUsageBreakdown(
            modelType: .opus,
            tokenCount: 2000,
            percentage: 40.0
        )
        let progressBar = ModelProgressBar(breakdown: breakdown)
        
        // Then - Should have correct accessibility traits
        XCTAssertTrue(progressBar.accessibilityTraits.contains(.updatesFrequently))
        XCTAssertTrue(progressBar.accessibilityTraits.contains(.summaryElement))
    }
    
    func testProgressBarAccessibilityLabels() {
        // Given - Different model types
        let opusBreakdown = ModelUsageBreakdown(modelType: .opus, tokenCount: 1500, percentage: 75.0)
        let sonnetBreakdown = ModelUsageBreakdown(modelType: .sonnet, tokenCount: 500, percentage: 25.0)
        
        // When - Creating progress bars
        let opusBar = ModelProgressBar(breakdown: opusBreakdown)
        let sonnetBar = ModelProgressBar(breakdown: sonnetBreakdown)
        
        // Then - Should have descriptive labels
        XCTAssertTrue(opusBar.accessibilityLabel.contains("Opus"))
        XCTAssertTrue(opusBar.accessibilityLabel.contains("75%"))
        XCTAssertTrue(sonnetBar.accessibilityLabel.contains("Sonnet"))
        XCTAssertTrue(sonnetBar.accessibilityLabel.contains("25%"))
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(tokenCount: Int, tokenLimit: Int) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: Date(),
            endTime: Date().addingTimeInterval(5 * 60 * 60),
            tokenCount: tokenCount,
            tokenLimit: tokenLimit,
            cost: 0.0,
            isActive: true,
            burnRate: 10.0
        )
    }
}