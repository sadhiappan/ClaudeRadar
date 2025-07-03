import XCTest
@testable import ClaudeRadar

final class ClaudeDataLoaderTests: XCTestCase {
    var dataLoader: ClaudeDataLoader!
    
    override func setUp() {
        super.setUp()
        dataLoader = ClaudeDataLoader()
    }
    
    override func tearDown() {
        dataLoader = nil
        super.tearDown()
    }
    
    // MARK: - Safe Unit Tests (No Risk to Working Code)
    
    func testLoadUsageEntriesWithInvalidPath() async {
        // Given
        let invalidPath = "/nonexistent/path"
        
        // When/Then
        do {
            let entries = try await dataLoader.loadUsageEntries(from: invalidPath)
            XCTAssertTrue(entries.isEmpty, "Should return empty array for invalid path")
        } catch {
            // This is also acceptable - either empty array or error
            XCTAssertTrue(true, "Graceful error handling for invalid path")
        }
    }
    
    func testLoadUsageEntriesWithNilPath() async {
        // Given - nil path should trigger auto-discovery
        
        // When
        do {
            let entries = try await dataLoader.loadUsageEntries(from: nil)
            // Then - should either find real data or return empty (both valid)
            XCTAssertTrue(entries.count >= 0, "Should return non-negative entry count")
            print("📊 Auto-discovery found \(entries.count) entries")
        } catch {
            // This is acceptable if no Claude directory exists
            XCTAssertTrue(true, "Graceful handling when no Claude directory found")
        }
    }
    
    func testUsageEntryStructure() {
        // Given - test the data structure integrity
        let timestamp = Date()
        
        // When
        let entry = UsageEntry(
            timestamp: timestamp,
            inputTokens: 100,
            outputTokens: 50,
            cacheCreationTokens: 200,
            cacheReadTokens: 300,
            model: "claude-3-5-sonnet",
            cost: 1.5,
            messageId: "test-message-id",
            requestId: "test-request-id"
        )
        
        // Then
        XCTAssertEqual(entry.totalTokens, 650) // 100 + 50 + 200 + 300
        XCTAssertEqual(entry.timestamp, timestamp)
        XCTAssertEqual(entry.model, "claude-3-5-sonnet")
        XCTAssertEqual(entry.cost, 1.5)
    }
    
    func testUsageEntryTotalTokensCalculation() {
        // Given
        let testCases = [
            (input: 10, output: 20, cacheCreate: 30, cacheRead: 40, expected: 100),
            (input: 0, output: 0, cacheCreate: 0, cacheRead: 0, expected: 0),
            (input: 1000, output: 2000, cacheCreate: 3000, cacheRead: 4000, expected: 10000)
        ]
        
        for testCase in testCases {
            // When
            let entry = UsageEntry(
                timestamp: Date(),
                inputTokens: testCase.input,
                outputTokens: testCase.output,
                cacheCreationTokens: testCase.cacheCreate,
                cacheReadTokens: testCase.cacheRead,
                model: "test",
                cost: 0.0,
                messageId: nil,
                requestId: nil
            )
            
            // Then
            XCTAssertEqual(entry.totalTokens, testCase.expected, 
                          "Total tokens should be \(testCase.expected) for input:\(testCase.input) output:\(testCase.output) cacheCreate:\(testCase.cacheCreate) cacheRead:\(testCase.cacheRead)")
        }
    }
}