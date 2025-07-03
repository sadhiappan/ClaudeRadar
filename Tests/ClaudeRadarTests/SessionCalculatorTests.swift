import XCTest
@testable import ClaudeRadar

final class SessionCalculatorTests: XCTestCase {
    var calculator: SessionCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = SessionCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    func testCalculateSessionsWithEmptyEntries() {
        // Given
        let entries: [UsageEntry] = []
        
        // When
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then
        XCTAssertTrue(sessions.isEmpty)
    }
    
    func testCalculateSessionsWithSingleEntry() {
        // Given
        let entries = [createMockEntry(timestamp: Date(), tokens: 100)]
        
        // When
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.tokenCount, 100)
        XCTAssertEqual(sessions.first?.tokenLimit, 7000)
    }
    
    func testCalculateSessionsWithMultipleEntriesInSameSession() {
        // Given
        let baseDate = Date()
        let entries = [
            createMockEntry(timestamp: baseDate, tokens: 100),
            createMockEntry(timestamp: baseDate.addingTimeInterval(3600), tokens: 200), // 1 hour later
            createMockEntry(timestamp: baseDate.addingTimeInterval(7200), tokens: 150)  // 2 hours later
        ]
        
        // When
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.tokenCount, 450) // 100 + 200 + 150
    }
    
    func testCalculateSessionsWithEntriesInDifferentSessions() {
        // Given
        let baseDate = Date()
        let entries = [
            createMockEntry(timestamp: baseDate, tokens: 100),
            createMockEntry(timestamp: baseDate.addingTimeInterval(6 * 3600), tokens: 200) // 6 hours later (new session)
        ]
        
        // When
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then
        XCTAssertEqual(sessions.count, 2)
        XCTAssertEqual(sessions[0].tokenCount, 200) // Most recent first
        XCTAssertEqual(sessions[1].tokenCount, 100)
    }
    
    func testCustomMaxPlanTokenLimitDetection() {
        // Given
        let entries = [createMockEntry(timestamp: Date(), tokens: 50000)]
        
        // When
        let sessions = calculator.calculateSessions(from: entries, plan: .customMax)
        
        // Then
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.tokenLimit, 140000) // Should detect Max20 limit
    }
    
    // MARK: - Helper Methods
    
    private func createMockEntry(timestamp: Date, tokens: Int) -> UsageEntry {
        return UsageEntry(
            timestamp: timestamp,
            inputTokens: tokens / 2,
            outputTokens: tokens / 2,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            model: "claude-3-5-sonnet-20241022",
            cost: Double(tokens) * 0.003 / 1000, // Approximate cost
            messageId: UUID().uuidString,
            requestId: UUID().uuidString
        )
    }
}