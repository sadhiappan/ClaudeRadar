import XCTest
@testable import ClaudeRadar

final class TokenPlanTests: XCTestCase {
    
    // MARK: - TDD Test 1: Token Limits Should Match Python Implementation
    
    func testTokenLimitsShouldMatchPythonClaudeMonitor() {
        // Given - The Python claude-monitor uses these accurate limits
        let expectedProLimit = 44_000
        let expectedMax5Limit = 220_000  
        let expectedMax20Limit = 880_000
        
        // When - We check our current token limits
        let proLimit = TokenPlan.pro.tokenLimit
        let max5Limit = TokenPlan.max5.tokenLimit
        let max20Limit = TokenPlan.max20.tokenLimit
        
        // Then - They should match the Python implementation
        XCTAssertEqual(proLimit, expectedProLimit, 
                      "Pro plan should have 44,000 token limit to match Python claude-monitor")
        XCTAssertEqual(max5Limit, expectedMax5Limit,
                      "Max5 plan should have 220,000 token limit to match Python claude-monitor")
        XCTAssertEqual(max20Limit, expectedMax20Limit,
                      "Max20 plan should have 880,000 token limit to match Python claude-monitor")
    }
    
    func testCustomMaxShouldDetectCorrectLimits() {
        // Given - A session with high token usage indicating Max20
        let highUsageSession = ClaudeSession(
            id: UUID().uuidString,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            tokenCount: 100_000, // High usage suggesting Max20
            tokenLimit: 7000, // Wrong limit - should be detected and corrected
            cost: 5.0,
            isActive: false,
            burnRate: nil
        )
        
        // When - We detect the plan from usage
        let detectedLimit = TokenPlan.customMax.detectTokenLimit(from: [highUsageSession])
        
        // Then - It should detect Max20 limit
        XCTAssertEqual(detectedLimit, 880_000, 
                      "Should detect Max20 limit (880K) from high usage session")
    }
}