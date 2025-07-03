import XCTest
@testable import ClaudeRadar

class ModelTrackingTests: XCTestCase {
    
    // MARK: - Session Model Tracking Tests
    
    func testSessionWithSingleModel() {
        // Given - Usage entries all from Opus
        let entries = [
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 100),
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 200),
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 150)
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then - Session should track Opus usage
        XCTAssertEqual(sessions.count, 1)
        let session = sessions[0]
        
        XCTAssertEqual(session.modelUsage.count, 1)
        XCTAssertEqual(session.modelUsage[.opus], 450) // 100 + 200 + 150
        XCTAssertEqual(session.primaryModel, .opus)
        XCTAssertEqual(session.modelBreakdown.count, 1)
    }
    
    func testSessionWithMultipleModels() {
        // Given - Mixed model usage
        let entries = [
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 300),
            createUsageEntry(model: "claude-3-5-sonnet-20241022", tokens: 100),
            createUsageEntry(model: "claude-3-haiku-20240307", tokens: 50),
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 200)
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then - Session should track all models
        XCTAssertEqual(sessions.count, 1)
        let session = sessions[0]
        
        // Verify model usage tracking
        XCTAssertEqual(session.modelUsage[.opus], 500) // 300 + 200
        XCTAssertEqual(session.modelUsage[.sonnet], 100)
        XCTAssertEqual(session.modelUsage[.haiku], 50)
        
        // Primary model should be the most used (Opus)
        XCTAssertEqual(session.primaryModel, .opus)
        
        // Total tokens should match
        XCTAssertEqual(session.tokenCount, 650)
    }
    
    func testSessionModelPercentages() {
        // Given - Mixed usage with known percentages
        let entries = [
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 670), // 67%
            createUsageEntry(model: "claude-3-5-sonnet-20241022", tokens: 280), // 28%  
            createUsageEntry(model: "claude-3-haiku-20240307", tokens: 50)  // 5%
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then - Model breakdown should show correct percentages
        let session = sessions[0]
        let breakdown = session.modelBreakdown
        
        XCTAssertEqual(breakdown.count, 3)
        
        // Find breakdown for each model
        let opusBreakdown = breakdown.first { $0.modelType == .opus }!
        let sonnetBreakdown = breakdown.first { $0.modelType == .sonnet }!
        let haikuBreakdown = breakdown.first { $0.modelType == .haiku }!
        
        XCTAssertEqual(opusBreakdown.percentage, 67.0, accuracy: 1.0)
        XCTAssertEqual(sonnetBreakdown.percentage, 28.0, accuracy: 1.0)
        XCTAssertEqual(haikuBreakdown.percentage, 5.0, accuracy: 1.0)
        
        // Verify token counts
        XCTAssertEqual(opusBreakdown.tokenCount, 670)
        XCTAssertEqual(sonnetBreakdown.tokenCount, 280)
        XCTAssertEqual(haikuBreakdown.tokenCount, 50)
    }
    
    func testUnknownModelHandling() {
        // Given - Entries with unknown model
        let entries = [
            createUsageEntry(model: "claude-4-future-model", tokens: 100),
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 200)
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then - Unknown model should be tracked separately
        let session = sessions[0]
        
        XCTAssertEqual(session.modelUsage[.opus], 200)
        XCTAssertEqual(session.modelUsage[.unknown], 100)
        XCTAssertEqual(session.primaryModel, .opus) // Opus has more usage
    }
    
    // MARK: - Model Breakdown Tests
    
    func testModelBreakdownSorting() {
        // Given - Mixed usage
        let entries = [
            createUsageEntry(model: "claude-3-haiku-20240307", tokens: 50),   // Least
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 500),   // Most
            createUsageEntry(model: "claude-3-5-sonnet-20241022", tokens: 200) // Middle
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let session = calculator.calculateSessions(from: entries, plan: .pro)[0]
        
        // Then - Breakdown should be sorted by usage (descending)
        let breakdown = session.modelBreakdown
        XCTAssertEqual(breakdown.count, 3)
        XCTAssertEqual(breakdown[0].modelType, .opus)    // 500 tokens (most)
        XCTAssertEqual(breakdown[1].modelType, .sonnet)  // 200 tokens
        XCTAssertEqual(breakdown[2].modelType, .haiku)   // 50 tokens (least)
    }
    
    func testEmptySessionModelTracking() {
        // Given - Empty usage entries
        let entries: [UsageEntry] = []
        
        // When - Create sessions
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then - Should return empty sessions
        XCTAssertEqual(sessions.count, 0)
    }
    
    // MARK: - Primary Model Logic Tests
    
    func testPrimaryModelWithTie() {
        // Given - Two models with equal usage
        let entries = [
            createUsageEntry(model: "claude-3-opus-20240229", tokens: 100),
            createUsageEntry(model: "claude-3-5-sonnet-20241022", tokens: 100)
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let session = calculator.calculateSessions(from: entries, plan: .pro)[0]
        
        // Then - Primary model should be the higher-tier model (Opus > Sonnet)
        XCTAssertEqual(session.primaryModel, .opus)
    }
    
    func testPrimaryModelWithSingleEntry() {
        // Given - Single usage entry
        let entries = [
            createUsageEntry(model: "claude-3-haiku-20240307", tokens: 50)
        ]
        
        // When - Create session
        let calculator = SessionCalculator()
        let session = calculator.calculateSessions(from: entries, plan: .pro)[0]
        
        // Then - Primary model should be that single model
        XCTAssertEqual(session.primaryModel, .haiku)
    }
    
    // MARK: - Helper Methods
    
    private func createUsageEntry(model: String, tokens: Int, timeOffset: TimeInterval = 0) -> UsageEntry {
        return UsageEntry(
            timestamp: Date().addingTimeInterval(timeOffset),
            inputTokens: tokens / 2,
            outputTokens: tokens / 2,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            model: model,
            cost: Double(tokens) * 0.001,
            messageId: UUID().uuidString,
            requestId: UUID().uuidString
        )
    }
}