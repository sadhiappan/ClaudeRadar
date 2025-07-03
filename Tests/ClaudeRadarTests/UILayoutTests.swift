import XCTest
@testable import ClaudeRadar

final class UILayoutTests: XCTestCase {
    
    // MARK: - TDD Test: Improved Metrics Layout (Python Parity)
    
    func testCurrentSessionViewShouldShowMetricsInCorrectOrder() {
        // Given - A session with burn rate and time remaining data
        let session = createMockSession(
            tokenCount: 13_056,
            tokenLimit: 44_000,
            burnRate: 43.5
        )
        
        // When - We analyze the session metrics layout
        let metricsData = session.metricsLayoutData
        
        // Then - Should organize metrics in optimal display order
        // Top Priority: Token usage, status
        XCTAssertEqual(metricsData.primaryTokenDisplay, "13,056 tokens used")
        XCTAssertEqual(metricsData.statusMessage, "Smooth sailing...")
        
        // Secondary Priority: Key metrics (burn rate, time remaining)
        XCTAssertEqual(metricsData.burnRateDisplay, "43.5 tokens/min")
        XCTAssertEqual(metricsData.timeRemainingDisplay, "11h 51m")
        
        // Tertiary Priority: Detailed usage info
        XCTAssertEqual(metricsData.usageBarDisplay, "13,056/44,000")
    }
    
    func testMetricsLayoutShouldHandleVaryingTimeFormats() {
        // Given - Sessions with different time remaining values
        let shortSession = createMockSession(tokenCount: 35_000, tokenLimit: 44_000, burnRate: 150.0) // ~4 minutes
        let mediumSession = createMockSession(tokenCount: 20_000, tokenLimit: 44_000, burnRate: 50.0) // ~8 hours
        let longSession = createMockSession(tokenCount: 5_000, tokenLimit: 44_000, burnRate: 10.0) // ~65 hours
        
        // When - We get time remaining displays
        let shortDisplay = shortSession.metricsLayoutData.timeRemainingDisplay
        let mediumDisplay = mediumSession.metricsLayoutData.timeRemainingDisplay  
        let longDisplay = longSession.metricsLayoutData.timeRemainingDisplay
        
        // Then - Should format appropriately for each duration
        XCTAssertEqual(shortDisplay, "4m", "Short duration should show minutes only")
        XCTAssertEqual(mediumDisplay, "8h 0m", "Medium duration should show hours and minutes")
        XCTAssertEqual(longDisplay, "65h 0m", "Long duration should show hours and minutes")
    }
    
    func testMetricsLayoutShouldHandleNoActiveSession() {
        // Given - No active session
        let expiredSession = createMockSession(
            tokenCount: 5_000,
            tokenLimit: 44_000,
            burnRate: nil,
            isActive: false
        )
        
        // When - We get the metrics layout
        let metricsData = expiredSession.metricsLayoutData
        
        // Then - Should show appropriate inactive state
        XCTAssertEqual(metricsData.primaryTokenDisplay, "No active session")
        XCTAssertEqual(metricsData.statusMessage, "Session expired")
        XCTAssertEqual(metricsData.burnRateDisplay, "—")
        XCTAssertEqual(metricsData.timeRemainingDisplay, "—")
    }
    
    func testMetricsLayoutShouldPrioritizeKeyInformation() {
        // Given - Session with all metrics available
        let session = createMockSession(
            tokenCount: 25_000,
            tokenLimit: 44_000,
            burnRate: 75.5
        )
        
        // When - We check the layout priority
        let layout = session.metricsLayoutData
        
        // Then - Should organize information by importance
        // Most Important: Current usage and status
        XCTAssertFalse(layout.primaryTokenDisplay.isEmpty)
        XCTAssertFalse(layout.statusMessage.isEmpty)
        
        // Highly Important: Active monitoring metrics
        XCTAssertFalse(layout.burnRateDisplay.isEmpty)
        XCTAssertFalse(layout.timeRemainingDisplay.isEmpty)
        
        // Supporting: Detailed breakdown
        XCTAssertFalse(layout.usageBarDisplay.isEmpty)
        
        // Should follow Python monitor's information hierarchy
        XCTAssertTrue(layout.prioritizesKeyMetrics, "Layout should prioritize burn rate and time remaining")
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

// MARK: - Test Data Structure

struct MetricsLayoutData {
    let primaryTokenDisplay: String
    let statusMessage: String
    let burnRateDisplay: String
    let timeRemainingDisplay: String
    let usageBarDisplay: String
    let prioritizesKeyMetrics: Bool
}