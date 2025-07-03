import XCTest
@testable import ClaudeRadar

final class ResetCountdownTests: XCTestCase {
    
    // MARK: - TDD Test: Reset Countdown Timer (Python Parity)
    
    func testShouldCalculateNextTokenResetTime() {
        // Given - Current time and reset hour (21:00 like Python monitor)
        let currentTime = createSpecificTime(hour: 14, minute: 30) // 2:30 PM
        let resetHour = 21 // 9:00 PM
        
        // When - We calculate next reset time
        let nextReset = calculateNextResetTime(currentTime: currentTime, resetHour: resetHour)
        let countdown = calculateTimeUntilReset(currentTime: currentTime, resetHour: resetHour)
        
        // Then - Should be 9:00 PM today (6.5 hours from now)
        let calendar = Calendar.current
        let resetComponents = calendar.dateComponents([.hour, .minute], from: nextReset)
        
        XCTAssertEqual(resetComponents.hour, 21, "Reset should be at 21:00 (9 PM)")
        XCTAssertEqual(resetComponents.minute, 0, "Reset should be at exact hour")
        
        // Should be 6.5 hours from now
        let hoursUntil = countdown / 3600
        XCTAssertEqual(hoursUntil, 6.5, accuracy: 0.1, "Should be 6.5 hours until reset")
    }
    
    func testShouldHandleResetTimePassedToday() {
        // Given - Current time after reset hour (e.g., 11 PM when reset is 9 PM)
        let currentTime = createSpecificTime(hour: 23, minute: 15) // 11:15 PM
        let resetHour = 21 // 9:00 PM
        
        // When - Calculate next reset (should be tomorrow)
        let nextReset = calculateNextResetTime(currentTime: currentTime, resetHour: resetHour)
        let countdown = calculateTimeUntilReset(currentTime: currentTime, resetHour: resetHour)
        
        // Then - Should be 9:00 PM tomorrow
        let hoursUntil = countdown / 3600
        XCTAssertEqual(hoursUntil, 21.75, accuracy: 0.1, "Should be ~21.75 hours until next reset")
        
        let calendar = Calendar.current
        let daysDiff = calendar.dateComponents([.day], from: currentTime, to: nextReset).day
        XCTAssertEqual(daysDiff, 1, "Reset should be tomorrow")
    }
    
    func testResetCountdownDisplayFormatting() {
        // Given - Various times until reset
        let now = Date()
        
        // Test different countdown scenarios
        let testCases = [
            (seconds: 2 * 3600 + 30 * 60, expected: "2h 30m"), // 2.5 hours
            (seconds: 45 * 60, expected: "45m"), // 45 minutes
            (seconds: 30, expected: "30s"), // 30 seconds
            (seconds: 25 * 3600, expected: "1d 1h") // 25 hours = 1 day 1 hour
        ]
        
        for testCase in testCases {
            // When - Format countdown
            let formatted = formatCountdownTime(testCase.seconds)
            
            // Then - Should format appropriately
            XCTAssertEqual(formatted, testCase.expected, 
                          "Should format \(testCase.seconds) seconds as '\(testCase.expected)'")
        }
    }
    
    func testResetCountdownWithDifferentResetHours() {
        // Given - Different reset hours
        let currentTime = createSpecificTime(hour: 10, minute: 0) // 10:00 AM
        
        let resetTimes = [
            (hour: 12, expectedHours: 2.0), // Noon (2 hours)
            (hour: 18, expectedHours: 8.0), // 6 PM (8 hours)
            (hour: 0, expectedHours: 14.0), // Midnight (14 hours)
            (hour: 6, expectedHours: 20.0)  // 6 AM tomorrow (20 hours)
        ]
        
        for resetTime in resetTimes {
            // When - Calculate countdown
            let countdown = calculateTimeUntilReset(
                currentTime: currentTime, 
                resetHour: resetTime.hour
            )
            
            // Then - Should match expected duration
            let hours = countdown / 3600
            XCTAssertEqual(hours, resetTime.expectedHours, accuracy: 0.1,
                          "Reset at \(resetTime.hour):00 should be \(resetTime.expectedHours) hours away")
        }
    }
    
    func testResetCountdownSessionIntegration() {
        // Given - Session with reset countdown integration
        let session = createMockSessionWithReset(
            currentTime: createSpecificTime(hour: 15, minute: 45), // 3:45 PM
            resetHour: 21 // 9 PM reset
        )
        
        // When - Get reset countdown display
        let layoutData = session.metricsLayoutData
        let resetDisplay = layoutData.resetCountdownDisplay
        
        // Then - Should show countdown to reset
        XCTAssertFalse(resetDisplay.isEmpty, "Should provide reset countdown")
        XCTAssertTrue(resetDisplay.contains("h") || resetDisplay.contains("m"), 
                     "Should show time format")
        
        // Should be approximately 5h 15m until 9 PM
        XCTAssertTrue(resetDisplay.contains("5h"), "Should show ~5 hours remaining")
    }
    
    func testResetCountdownEdgeCases() {
        // Given - Edge cases
        let almostReset = createSpecificTime(hour: 20, minute: 59) // 8:59 PM (1 min to 9 PM)
        let exactReset = createSpecificTime(hour: 21, minute: 0) // Exactly 9:00 PM
        let justPastReset = createSpecificTime(hour: 21, minute: 1) // 9:01 PM
        
        // When/Then - Handle edge cases
        let almostCountdown = calculateTimeUntilReset(currentTime: almostReset, resetHour: 21)
        XCTAssertEqual(almostCountdown / 60, 1, accuracy: 0.1, "Should be 1 minute until reset")
        
        let exactCountdown = calculateTimeUntilReset(currentTime: exactReset, resetHour: 21)
        XCTAssertEqual(exactCountdown / 3600, 24, accuracy: 0.1, "Should be 24 hours until next reset")
        
        let pastCountdown = calculateTimeUntilReset(currentTime: justPastReset, resetHour: 21)
        XCTAssertGreaterThan(pastCountdown / 3600, 23, "Should be almost 24 hours until next reset")
    }
    
    // MARK: - Helper Methods
    
    private func createSpecificTime(hour: Int, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 30
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
    
    private func createMockSessionWithReset(currentTime: Date, resetHour: Int) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: currentTime.addingTimeInterval(-3600),
            endTime: currentTime.addingTimeInterval(4 * 3600),
            tokenCount: 20_000,
            tokenLimit: 44_000,
            cost: 60.0,
            isActive: true,
            burnRate: 50.0
        )
    }
    
    // Test helper functions (to be implemented)
    private func calculateNextResetTime(currentTime: Date, resetHour: Int) -> Date {
        let calendar = Calendar.current
        var resetComponents = calendar.dateComponents([.year, .month, .day], from: currentTime)
        resetComponents.hour = resetHour
        resetComponents.minute = 0
        resetComponents.second = 0
        
        guard let todayReset = calendar.date(from: resetComponents) else {
            return currentTime
        }
        
        if todayReset > currentTime {
            return todayReset // Reset is later today
        } else {
            return calendar.date(byAdding: .day, value: 1, to: todayReset) ?? todayReset // Tomorrow
        }
    }
    
    private func calculateTimeUntilReset(currentTime: Date, resetHour: Int) -> TimeInterval {
        let nextReset = calculateNextResetTime(currentTime: currentTime, resetHour: resetHour)
        return nextReset.timeIntervalSince(currentTime)
    }
    
    private func formatCountdownTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let days = totalSeconds / (24 * 3600)
        let hours = (totalSeconds % (24 * 3600)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let remainingSeconds = totalSeconds % 60
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}