import XCTest
@testable import ClaudeRadar

final class StatusMessageTests: XCTestCase {
    
    // MARK: - TDD Test: Status Message System (Python Parity)
    
    func testShouldShowSmoothSailingForLowUsage() {
        // Given - Low usage session (< 30% of limit)
        let session = createMockSession(
            tokenCount: 10_000,
            tokenLimit: 44_000, // ~23% usage
            burnRate: 20.0
        )
        
        // When - We get the status message
        let status = session.statusMessage
        
        // Then - Should show smooth sailing message
        XCTAssertEqual(status, "Smooth sailing...", 
                      "Low usage (23%) should show 'Smooth sailing...' message")
    }
    
    func testShouldShowModerateUsageForMediumUsage() {
        // Given - Medium usage session (30-60% of limit)
        let session = createMockSession(
            tokenCount: 20_000,
            tokenLimit: 44_000, // ~45% usage
            burnRate: 40.0
        )
        
        // When - We get the status message
        let status = session.statusMessage
        
        // Then - Should show moderate usage message
        XCTAssertEqual(status, "Steady usage pace", 
                      "Medium usage (45%) should show 'Steady usage pace' message")
    }
    
    func testShouldShowHighUsageForHeavyUsage() {
        // Given - High usage session (60-85% of limit)
        let session = createMockSession(
            tokenCount: 32_000,
            tokenLimit: 44_000, // ~73% usage
            burnRate: 80.0
        )
        
        // When - We get the status message
        let status = session.statusMessage
        
        // Then - Should show high usage warning
        XCTAssertEqual(status, "High burn rate detected", 
                      "High usage (73%) should show 'High burn rate detected' message")
    }
    
    func testShouldShowCriticalForNearLimit() {
        // Given - Critical usage session (> 85% of limit)
        let session = createMockSession(
            tokenCount: 40_000,
            tokenLimit: 44_000, // ~91% usage
            burnRate: 120.0
        )
        
        // When - We get the status message
        let status = session.statusMessage
        
        // Then - Should show critical warning
        XCTAssertEqual(status, "Limit approaching - slow down", 
                      "Critical usage (91%) should show 'Limit approaching - slow down' message")
    }
    
    func testShouldConsiderBurnRateInStatusMessage() {
        // Given - Medium usage but very high burn rate
        let lowUsageHighBurn = createMockSession(
            tokenCount: 15_000,
            tokenLimit: 44_000, // ~34% usage
            burnRate: 150.0 // Very high burn rate
        )
        
        // When - We get the status message
        let status = lowUsageHighBurn.statusMessage
        
        // Then - Should escalate warning due to high burn rate
        XCTAssertEqual(status, "High burn rate detected", 
                      "High burn rate (150 tokens/min) should escalate status even with medium usage")
    }
    
    func testShouldHandleNoActiveSession() {
        // Given - No active session (expired)
        let expiredSession = createMockSession(
            tokenCount: 5_000,
            tokenLimit: 44_000,
            burnRate: nil,
            isActive: false
        )
        
        // When - We get the status message
        let status = expiredSession.statusMessage
        
        // Then - Should show session expired message
        XCTAssertEqual(status, "Session expired", 
                      "Expired session should show 'Session expired' message")
    }
    
    func testShouldProvideStatusColorCoding() {
        // Given - Different usage levels
        let lowUsage = createMockSession(tokenCount: 10_000, tokenLimit: 44_000, burnRate: 20.0)
        let mediumUsage = createMockSession(tokenCount: 20_000, tokenLimit: 44_000, burnRate: 40.0)
        let highUsage = createMockSession(tokenCount: 32_000, tokenLimit: 44_000, burnRate: 80.0)
        let criticalUsage = createMockSession(tokenCount: 40_000, tokenLimit: 44_000, burnRate: 120.0)
        
        // When/Then - Should provide appropriate status colors
        XCTAssertEqual(lowUsage.statusColor, .green, "Low usage should be green")
        XCTAssertEqual(mediumUsage.statusColor, .yellow, "Medium usage should be yellow")
        XCTAssertEqual(highUsage.statusColor, .orange, "High usage should be orange")
        XCTAssertEqual(criticalUsage.statusColor, .red, "Critical usage should be red")
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(
        tokenCount: Int,
        tokenLimit: Int,
        burnRate: Double?,
        isActive: Bool = true
    ) -> ClaudeSession {
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: Date().addingTimeInterval(-3600), // 1 hour ago
            endTime: Date().addingTimeInterval(14400), // 4 hours from now
            tokenCount: tokenCount,
            tokenLimit: tokenLimit,
            cost: Double(tokenCount) * 0.003 / 1000,
            isActive: isActive,
            burnRate: burnRate
        )
    }
}