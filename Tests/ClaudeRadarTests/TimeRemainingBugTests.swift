import XCTest
@testable import ClaudeRadar

final class TimeRemainingBugTests: XCTestCase {
    
    // MARK: - TDD Test: Fix Time Remaining Calculation Bug
    
    func testTimeRemainingShouldBeReasonableForActiveSession() {
        // Given - Real scenario: 13,758 tokens at 45.9 tokens/min
        let session = createMockSession(
            tokenCount: 13_758,
            tokenLimit: 44_000,
            burnRate: 45.9, // Current burn rate
            startTime: Date().addingTimeInterval(-3600), // Started 1 hour ago
            endTime: Date().addingTimeInterval(4 * 3600), // Ends in 4 hours
            isActive: true
        )
        
        // When - We calculate time remaining
        let timeRemaining = session.timeRemaining
        let formattedTime = session.metricsLayoutData.timeRemainingDisplay
        
        // Then - Should be reasonable (not 659+ hours!)
        XCTAssertNotNil(timeRemaining, "Active session should have time remaining")
        
        if let remaining = timeRemaining {
            let hours = remaining / 3600
            XCTAssertLessThan(hours, 24, "Time remaining should be less than 24 hours, got \(hours)")
            XCTAssertGreaterThan(hours, 0.1, "Time remaining should be positive")
            
            // For 30,242 remaining tokens at 45.9 tokens/min = ~659 minutes = ~11 hours
            let expectedHours = Double(session.remainingTokens) / session.burnRate! / 60
            XCTAssertEqual(hours, expectedHours, accuracy: 1.0, 
                          "Time remaining should match: \(session.remainingTokens) tokens ÷ \(session.burnRate!) tokens/min ÷ 60 = \(expectedHours) hours")
        }
        
        // Should format as reasonable time
        XCTAssertFalse(formattedTime.contains("659"), "Should not show 659+ hours")
        XCTAssertTrue(formattedTime.contains("h"), "Should show hours format")
    }
    
    func testTimeRemainingCalculationLogic() {
        // Given - Known values for precise testing
        let session = createMockSession(
            tokenCount: 20_000,
            tokenLimit: 44_000, // 24,000 tokens remaining
            burnRate: 60.0, // 60 tokens per minute
            startTime: Date().addingTimeInterval(-1800), // 30 min ago
            endTime: Date().addingTimeInterval(4.5 * 3600), // 4.5 hours from now
            isActive: true
        )
        
        // When - Calculate remaining time
        let timeRemaining = session.timeRemaining
        
        // Then - Should match manual calculation
        // 24,000 remaining tokens ÷ 60 tokens/min = 400 minutes = 6.67 hours
        let expectedMinutes = Double(session.remainingTokens) / session.burnRate!
        let expectedSeconds = expectedMinutes * 60
        
        XCTAssertNotNil(timeRemaining)
        XCTAssertEqual(timeRemaining!, expectedSeconds, accuracy: 60, 
                      "Should calculate: \(session.remainingTokens) tokens ÷ \(session.burnRate!) tokens/min = \(expectedMinutes) minutes")
        
        // Should be approximately 6.67 hours
        let hours = timeRemaining! / 3600
        XCTAssertEqual(hours, 6.67, accuracy: 0.1, "Should be ~6.67 hours")
    }
    
    func testTimeRemainingFormatting() {
        // Given - Different time remaining scenarios
        let shortTime = createMockSession(tokenCount: 43_000, tokenLimit: 44_000, burnRate: 120.0) // ~0.5 hours
        let mediumTime = createMockSession(tokenCount: 35_000, tokenLimit: 44_000, burnRate: 30.0) // ~5 hours  
        let longTime = createMockSession(tokenCount: 10_000, tokenLimit: 44_000, burnRate: 20.0) // ~28 hours
        
        // When - Format time remaining
        let shortFormat = shortTime.metricsLayoutData.timeRemainingDisplay
        let mediumFormat = mediumTime.metricsLayoutData.timeRemainingDisplay
        let longFormat = longTime.metricsLayoutData.timeRemainingDisplay
        
        // Then - Should format appropriately
        XCTAssertTrue(shortFormat.hasSuffix("m") || shortFormat.contains("h"), "Short time should show minutes or hours")
        XCTAssertTrue(mediumFormat.contains("h"), "Medium time should show hours")
        
        // Long time should cap at reasonable display (not show 100+ hours)
        XCTAssertFalse(longFormat.contains("28h"), "Should not show excessively long times")
    }
    
    func testTimeRemainingEdgeCases() {
        // Given - Edge cases
        let nearEmpty = createMockSession(tokenCount: 43_900, tokenLimit: 44_000, burnRate: 10.0) // 100 tokens left
        let noBurnRate = createMockSession(tokenCount: 20_000, tokenLimit: 44_000, burnRate: nil)
        let zeroBurnRate = createMockSession(tokenCount: 20_000, tokenLimit: 44_000, burnRate: 0.0)
        
        // When/Then - Handle edge cases gracefully
        XCTAssertNotNil(nearEmpty.timeRemaining, "Should handle near-empty session")
        XCTAssertNil(noBurnRate.timeRemaining, "Should return nil for no burn rate")
        XCTAssertNil(zeroBurnRate.timeRemaining, "Should return nil for zero burn rate")
        
        XCTAssertEqual(noBurnRate.metricsLayoutData.timeRemainingDisplay, "—")
        XCTAssertEqual(zeroBurnRate.metricsLayoutData.timeRemainingDisplay, "—")
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(
        tokenCount: Int,
        tokenLimit: Int,
        burnRate: Double?,
        startTime: Date = Date().addingTimeInterval(-3600),
        endTime: Date = Date().addingTimeInterval(4 * 3600),
        isActive: Bool = true
    ) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: startTime,
            endTime: endTime,
            tokenCount: tokenCount,
            tokenLimit: tokenLimit,
            cost: Double(tokenCount) * 0.003 / 1000,
            isActive: isActive,
            burnRate: burnRate
        )
    }
}