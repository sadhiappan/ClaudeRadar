import XCTest
@testable import ClaudeRadar

final class PredictedEndTimeTests: XCTestCase {
    
    // MARK: - TDD Test: Predicted End Time (Python Parity)
    
    func testShouldCalculatePredictedSessionEndTime() {
        // Given - Current session with known burn rate
        let now = Date()
        let session = createMockSession(
            tokenCount: 13_959,
            tokenLimit: 44_000,
            burnRate: 46.5, // tokens per minute
            startTime: now.addingTimeInterval(-3600), // Started 1 hour ago
            currentTime: now
        )
        
        // When - We calculate predicted end time
        let predictedEnd = session.predictedEndTime
        let predictedEndDisplay = session.predictedEndTimeDisplay
        
        // Then - Should predict when session will end based on current burn rate
        XCTAssertNotNil(predictedEnd, "Should calculate predicted end time for active session")
        
        if let endTime = predictedEnd {
            // Remaining tokens: 44,000 - 13,959 = 30,041
            // At 46.5 tokens/min: 30,041 ÷ 46.5 = ~646 minutes = ~10.8 hours
            // So should end ~10.8 hours from now
            
            let timeFromNow = endTime.timeIntervalSince(now)
            let hoursFromNow = timeFromNow / 3600
            
            XCTAssertEqual(hoursFromNow, 10.8, accuracy: 0.5, 
                          "Should predict end in ~10.8 hours based on burn rate")
        }
        
        // Should format as time (e.g., "02:47")
        XCTAssertFalse(predictedEndDisplay.isEmpty, "Should provide formatted display time")
        XCTAssertTrue(predictedEndDisplay.contains(":"), "Should format as HH:MM time")
    }
    
    func testPredictedEndTimeShouldHandleVariousBurnRates() {
        // Given - Different burn rate scenarios
        let now = Date()
        
        let slowBurn = createMockSession(
            tokenCount: 20_000, tokenLimit: 44_000, burnRate: 10.0, // Very slow
            startTime: now.addingTimeInterval(-1800), currentTime: now
        )
        
        let fastBurn = createMockSession(
            tokenCount: 35_000, tokenLimit: 44_000, burnRate: 100.0, // Very fast
            startTime: now.addingTimeInterval(-900), currentTime: now
        )
        
        // When - Calculate predicted end times
        let slowEnd = slowBurn.predictedEndTime
        let fastEnd = fastBurn.predictedEndTime
        
        // Then - Should predict vastly different end times
        XCTAssertNotNil(slowEnd)
        XCTAssertNotNil(fastEnd)
        
        if let slow = slowEnd, let fast = fastEnd {
            let slowHours = slow.timeIntervalSince(now) / 3600
            let fastHours = fast.timeIntervalSince(now) / 3600
            
            // 24,000 tokens ÷ 10 tokens/min = 2400 min = 40 hours
            XCTAssertEqual(slowHours, 40, accuracy: 2, "Slow burn should predict ~40 hours")
            
            // 9,000 tokens ÷ 100 tokens/min = 90 min = 1.5 hours  
            XCTAssertEqual(fastHours, 1.5, accuracy: 0.2, "Fast burn should predict ~1.5 hours")
            
            XCTAssertGreaterThan(slowHours, fastHours, "Slow burn should predict later end time")
        }
    }
    
    func testPredictedEndTimeDisplayFormatting() {
        // Given - Session that should end at a specific time
        let now = createSpecificTime(hour: 14, minute: 30) // 2:30 PM
        let session = createMockSession(
            tokenCount: 40_000, tokenLimit: 44_000, burnRate: 60.0, // 1 token per second
            startTime: now.addingTimeInterval(-1800), currentTime: now
        )
        
        // When - Get display format
        let display = session.predictedEndTimeDisplay
        
        // Then - Should format as readable time
        // 4,000 tokens ÷ 60 tokens/min = ~67 minutes = ~1.1 hours
        // So should end around 3:37 PM
        
        XCTAssertFalse(display.isEmpty, "Should provide formatted time")
        XCTAssertTrue(display.contains(":"), "Should contain time separator")
        
        // Should be in reasonable time format (not include date)
        XCTAssertFalse(display.contains("/"), "Should not include date")
        XCTAssertFalse(display.contains("2025"), "Should not include year")
    }
    
    func testPredictedEndTimeShouldHandleEdgeCases() {
        // Given - Edge cases
        let now = Date()
        
        let noBurnRate = createMockSession(
            tokenCount: 20_000, tokenLimit: 44_000, burnRate: nil,
            startTime: now.addingTimeInterval(-3600), currentTime: now
        )
        
        let nearComplete = createMockSession(
            tokenCount: 43_950, tokenLimit: 44_000, burnRate: 50.0, // 50 tokens left
            startTime: now.addingTimeInterval(-3600), currentTime: now
        )
        
        let inactiveSession = createMockSession(
            tokenCount: 20_000, tokenLimit: 44_000, burnRate: 50.0,
            startTime: now.addingTimeInterval(-6 * 3600), currentTime: now,
            isActive: false
        )
        
        // When/Then - Handle edge cases gracefully
        XCTAssertNil(noBurnRate.predictedEndTime, "Should return nil for no burn rate")
        XCTAssertEqual(noBurnRate.predictedEndTimeDisplay, "—")
        
        XCTAssertNotNil(nearComplete.predictedEndTime, "Should handle near-complete session")
        
        XCTAssertNil(inactiveSession.predictedEndTime, "Should return nil for inactive session")
        XCTAssertEqual(inactiveSession.predictedEndTimeDisplay, "—")
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(
        tokenCount: Int,
        tokenLimit: Int,
        burnRate: Double?,
        startTime: Date,
        currentTime: Date = Date(),
        isActive: Bool = true
    ) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: startTime,
            endTime: startTime.addingTimeInterval(5 * 3600), // 5 hours later
            tokenCount: tokenCount,
            tokenLimit: tokenLimit,
            cost: Double(tokenCount) * 0.003 / 1000,
            isActive: isActive,
            burnRate: burnRate
        )
    }
    
    private func createSpecificTime(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 30
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
}