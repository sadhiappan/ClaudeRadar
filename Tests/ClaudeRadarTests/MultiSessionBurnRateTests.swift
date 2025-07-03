import XCTest
@testable import ClaudeRadar

final class MultiSessionBurnRateTests: XCTestCase {
    var calculator: SessionCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = SessionCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - TDD Test: Multi-Session Burn Rate (Python Parity)
    
    func testShouldCalculateAggregatedBurnRateAcrossRecentSessions() {
        // Given - Multiple sessions in the last hour (Python approach)
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-3600) // 1 hour ago
        let thirtyMinAgo = now.addingTimeInterval(-1800) // 30 min ago
        
        let sessions = [
            createMockSession(
                startTime: oneHourAgo,
                endTime: oneHourAgo.addingTimeInterval(1800), // 30 min duration
                tokenCount: 900, // 30 tokens/min
                isActive: false
            ),
            createMockSession(
                startTime: thirtyMinAgo,
                endTime: now,
                tokenCount: 1500, // 50 tokens/min
                isActive: true
            )
        ]
        
        // When - We calculate multi-session burn rate
        let aggregatedBurnRate = calculator.calculateHourlyAggregatedBurnRate(
            from: sessions, 
            currentTime: now
        )
        
        // Then - Should average across both sessions proportionally
        // Session 1: 900 tokens / 30 min = 30 tokens/min (weight: 30min/60min = 0.5)
        // Session 2: 1500 tokens / 30 min = 50 tokens/min (weight: 30min/60min = 0.5)
        // Expected: (30 * 0.5) + (50 * 0.5) = 40 tokens/min
        
        XCTAssertNotNil(aggregatedBurnRate, "Should calculate aggregated burn rate")
        XCTAssertEqual(aggregatedBurnRate!, 40.0, accuracy: 1.0,
                      "Should calculate weighted average: (30*0.5) + (50*0.5) = 40 tokens/min")
    }
    
    func testShouldHandlePartialSessionsInLastHour() {
        // Given - Session that extends beyond the 1-hour window
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-7200) // 2 hours ago
        let oneHourAgo = now.addingTimeInterval(-3600) // 1 hour ago
        
        let sessions = [
            createMockSession(
                startTime: twoHoursAgo,
                endTime: now, // 2 hour duration, but only 1 hour in window
                tokenCount: 7200, // 60 tokens/min over 2 hours
                isActive: true
            )
        ]
        
        // When - We calculate burn rate for last hour only
        let burnRate = calculator.calculateHourlyAggregatedBurnRate(
            from: sessions,
            currentTime: now
        )
        
        // Then - Should only count tokens from the last hour
        // 3600 tokens in the last hour (half of 7200) / 60 minutes = 60 tokens/min
        XCTAssertNotNil(burnRate)
        XCTAssertEqual(burnRate!, 60.0, accuracy: 1.0,
                      "Should calculate burn rate for last hour only: 3600 tokens / 60 min = 60 tokens/min")
    }
    
    func testShouldReturnNilForNoRecentActivity() {
        // Given - No sessions in the last hour
        let now = Date()
        let twoHoursAgo = now.addingTimeInterval(-7200)
        
        let sessions = [
            createMockSession(
                startTime: twoHoursAgo,
                endTime: twoHoursAgo.addingTimeInterval(1800), // Ended 1.5 hours ago
                tokenCount: 1000,
                isActive: false
            )
        ]
        
        // When - We calculate burn rate
        let burnRate = calculator.calculateHourlyAggregatedBurnRate(
            from: sessions,
            currentTime: now
        )
        
        // Then - Should return nil (no activity in last hour)
        XCTAssertNil(burnRate, "Should return nil when no activity in last hour")
    }
    
    func testShouldMatchPythonCalculationLogic() {
        // Given - Real-world scenario matching Python logic
        let now = Date()
        let fiftyMinAgo = now.addingTimeInterval(-3000) // 50 minutes ago
        let twentyMinAgo = now.addingTimeInterval(-1200) // 20 minutes ago
        
        // Two overlapping sessions like Python handles
        let sessions = [
            createMockSession(
                startTime: fiftyMinAgo,
                endTime: twentyMinAgo, // 30 min session
                tokenCount: 1800, // 60 tokens/min
                isActive: false
            ),
            createMockSession(
                startTime: twentyMinAgo,
                endTime: now, // 20 min session
                tokenCount: 1000, // 50 tokens/min
                isActive: true
            )
        ]
        
        // When - Calculate aggregated rate
        let burnRate = calculator.calculateHourlyAggregatedBurnRate(
            from: sessions,
            currentTime: now
        )
        
        // Then - Should properly weight the overlapping periods
        // Total: 2800 tokens over 50 minutes = 56 tokens/min
        XCTAssertNotNil(burnRate)
        XCTAssertEqual(burnRate!, 56.0, accuracy: 2.0,
                      "Should handle overlapping sessions: 2800 tokens / 50 min ≈ 56 tokens/min")
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(
        startTime: Date,
        endTime: Date,
        tokenCount: Int,
        isActive: Bool
    ) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: startTime,
            endTime: endTime,
            tokenCount: tokenCount,
            tokenLimit: 44_000, // Use correct Pro limit
            cost: Double(tokenCount) * 0.003 / 1000,
            isActive: isActive,
            burnRate: nil // Will be calculated
        )
    }
}