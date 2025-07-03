import XCTest
@testable import ClaudeRadar

final class SessionAlignmentTests: XCTestCase {
    var calculator: SessionCalculator!
    
    override func setUp() {
        super.setUp()
        calculator = SessionCalculator()
    }
    
    override func tearDown() {
        calculator = nil
        super.tearDown()
    }
    
    // MARK: - TDD Test 2: Hour-Aligned Session Boundaries
    
    func testSessionsShouldBeHourAligned() {
        // Given - Entries at non-hour-aligned times (like Python claude-monitor)
        let baseDate = createDate(hour: 14, minute: 23, second: 45) // 2:23:45 PM
        let entries = [
            createMockEntry(timestamp: baseDate, tokens: 100),
            createMockEntry(timestamp: baseDate.addingTimeInterval(1800), tokens: 200) // 30 min later
        ]
        
        // When - We calculate sessions
        let sessions = calculator.calculateHourAlignedSessions(from: entries, plan: .pro)
        
        // Then - Session should start at nearest hour (2:00 PM)
        let expectedStart = createDate(hour: 14, minute: 0, second: 0) // 2:00 PM
        let expectedEnd = expectedStart.addingTimeInterval(5 * 3600) // 7:00 PM (5 hours later)
        
        XCTAssertEqual(sessions.count, 1, "Should create one session block")
        
        let session = sessions.first!
        XCTAssertEqual(session.startTime, expectedStart, 
                      "Session should start at hour boundary (2:00 PM), not at first entry time")
        XCTAssertEqual(session.endTime, expectedEnd,
                      "Session should end exactly 5 hours after start (7:00 PM)")
        XCTAssertEqual(session.tokenCount, 300, "Should include all tokens in the block")
    }
    
    func testShouldDetectGapsBetweenSessions() {
        // Given - Entries with a significant gap (like Python claude-monitor gap detection)
        let firstSessionTime = createDate(hour: 10, minute: 30, second: 0) // 10:30 AM
        let secondSessionTime = createDate(hour: 16, minute: 15, second: 0) // 4:15 PM (5h 45m later)
        
        let entries = [
            createMockEntry(timestamp: firstSessionTime, tokens: 100),
            createMockEntry(timestamp: secondSessionTime, tokens: 200)
        ]
        
        // When - We calculate sessions with gap detection
        let sessions = calculator.calculateHourAlignedSessions(from: entries, plan: .pro)
        
        // Then - Should create two separate sessions due to gap
        XCTAssertEqual(sessions.count, 2, "Should detect gap and create two separate sessions")
        
        // First session: 10:00 AM - 3:00 PM  
        let firstSession = sessions.first!
        XCTAssertEqual(firstSession.startTime, createDate(hour: 10, minute: 0, second: 0))
        XCTAssertEqual(firstSession.endTime, createDate(hour: 15, minute: 0, second: 0))
        XCTAssertEqual(firstSession.tokenCount, 100)
        
        // Second session: 4:00 PM - 9:00 PM
        let secondSession = sessions.last!
        XCTAssertEqual(secondSession.startTime, createDate(hour: 16, minute: 0, second: 0))
        XCTAssertEqual(secondSession.endTime, createDate(hour: 21, minute: 0, second: 0))
        XCTAssertEqual(secondSession.tokenCount, 200)
    }
    
    // MARK: - Helper Methods
    
    private func createDate(hour: Int, minute: Int, second: Int) -> Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 30
        components.hour = hour
        components.minute = minute
        components.second = second
        return Calendar.current.date(from: components)!
    }
    
    private func createMockEntry(timestamp: Date, tokens: Int) -> UsageEntry {
        return UsageEntry(
            timestamp: timestamp,
            inputTokens: tokens / 2,
            outputTokens: tokens / 2,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            model: "claude-3-5-sonnet-20241022",
            cost: Double(tokens) * 0.003 / 1000,
            messageId: UUID().uuidString,
            requestId: UUID().uuidString
        )
    }
}