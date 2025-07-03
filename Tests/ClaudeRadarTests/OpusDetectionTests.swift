import XCTest
@testable import ClaudeRadar

class OpusDetectionTests: XCTestCase {
    
    // MARK: - Opus Model Detection Tests
    
    func testOpusModelDetection() {
        // Given - Common Opus model string formats including Opus 4
        let opusModelStrings = [
            "claude-3-opus-20240229",
            "claude-opus-4-20250514", // Opus 4 format from recent logs
            "claude-3-opus",
            "opus",
            "Claude 3 Opus",
            "claude-opus-3",
            "claude-3-opus-latest"
        ]
        
        // When - Testing model detection
        for modelString in opusModelStrings {
            let detectedModel = ModelInfo.from(modelString)
            
            // Then - Should detect as Opus
            XCTAssertEqual(detectedModel.type, .opus, 
                          "Failed to detect '\(modelString)' as Opus, got \(detectedModel.type)")
        }
    }
    
    func testCurrentOpusModelString() {
        // Given - Current Opus model string (as of 2024)
        let currentOpusModel = "claude-3-opus-20240229"
        
        // When - Detecting model
        let detectedModel = ModelInfo.from(currentOpusModel)
        
        // Then - Should be Opus
        XCTAssertEqual(detectedModel.type, .opus)
        XCTAssertEqual(detectedModel.displayName, "Claude 3 Opus")
        XCTAssertEqual(detectedModel.shortName, "Opus")
    }
    
    func testOpus4ModelString() {
        // Given - Opus 4 model string (as of 2025)
        let opus4Model = "claude-opus-4-20250514"
        
        // When - Detecting model
        let detectedModel = ModelInfo.from(opus4Model)
        
        // Then - Should be Opus
        XCTAssertEqual(detectedModel.type, .opus)
        XCTAssertEqual(detectedModel.displayName, "Claude 3 Opus")
        XCTAssertEqual(detectedModel.shortName, "Opus")
    }
    
    func testOpusVsSonnetDistinction() {
        // Given - Similar model strings
        let opusString = "claude-3-opus-20240229"
        let sonnetString = "claude-3-5-sonnet-20241022"
        
        // When - Detecting models
        let opusModel = ModelInfo.from(opusString)
        let sonnetModel = ModelInfo.from(sonnetString)
        
        // Then - Should distinguish correctly
        XCTAssertEqual(opusModel.type, .opus)
        XCTAssertEqual(sonnetModel.type, .sonnet)
        XCTAssertNotEqual(opusModel.type, sonnetModel.type)
    }
    
    func testSessionModelAggregation() {
        // Given - Mixed Opus 4 and Sonnet entries
        let entries = [
            createUsageEntry(model: "claude-opus-4-20250514", inputTokens: 100, outputTokens: 50),
            createUsageEntry(model: "claude-3-5-sonnet-20241022", inputTokens: 200, outputTokens: 100),
            createUsageEntry(model: "claude-opus-4-20250514", inputTokens: 150, outputTokens: 75)
        ]
        
        // When - Creating session
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: entries, plan: .pro)
        
        // Then - Should aggregate both models correctly
        XCTAssertEqual(sessions.count, 1)
        let session = sessions[0]
        
        XCTAssertEqual(session.modelUsage[.opus], 375) // 150 + 225
        XCTAssertEqual(session.modelUsage[.sonnet], 300) // 300
        XCTAssertEqual(session.modelBreakdown.count, 2)
        
        // Primary model should be Opus (more usage)
        XCTAssertEqual(session.primaryModel, .opus)
    }
    
    func testOpusModelBreakdownPercentages() {
        // Given - Entries with known token distribution
        let entries = [
            createUsageEntry(model: "claude-3-opus-20240229", inputTokens: 300, outputTokens: 200), // 500 tokens
            createUsageEntry(model: "claude-3-5-sonnet-20241022", inputTokens: 100, outputTokens: 100) // 200 tokens
        ]
        
        // When - Creating session
        let calculator = SessionCalculator()
        let session = calculator.calculateSessions(from: entries, plan: .pro)[0]
        
        // Then - Should calculate correct percentages
        let breakdown = session.modelBreakdown
        let opusBreakdown = breakdown.first { $0.modelType == .opus }!
        let sonnetBreakdown = breakdown.first { $0.modelType == .sonnet }!
        
        XCTAssertEqual(opusBreakdown.percentage, 71.4, accuracy: 0.1) // 500/700
        XCTAssertEqual(sonnetBreakdown.percentage, 28.6, accuracy: 0.1) // 200/700
    }
    
    func testOpusFilteringInProgressBars() {
        // Given - Model breakdown with Opus usage
        let breakdowns = [
            ModelUsageBreakdown(modelType: .opus, tokenCount: 500, percentage: 60.0),
            ModelUsageBreakdown(modelType: .sonnet, tokenCount: 300, percentage: 36.0),
            ModelUsageBreakdown(modelType: .unknown, tokenCount: 10, percentage: 4.0)
        ]
        
        // When - Creating progress collection
        let progressCollection = ModelProgressCollection(breakdowns: breakdowns, style: .compact)
        
        // Then - Should include Opus and Sonnet, exclude Unknown
        let filteredBreakdowns = progressCollection.filteredBreakdowns
        XCTAssertEqual(filteredBreakdowns.count, 2)
        XCTAssertTrue(filteredBreakdowns.contains { $0.modelType == .opus })
        XCTAssertTrue(filteredBreakdowns.contains { $0.modelType == .sonnet })
        XCTAssertFalse(filteredBreakdowns.contains { $0.modelType == .unknown })
    }
    
    func testRealTimeOpusDetection() {
        // Given - Real-time usage entry (simulating current Opus usage)
        let currentTime = Date()
        let opusEntry = UsageEntry(
            timestamp: currentTime,
            inputTokens: 25,
            outputTokens: 8,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            model: "claude-3-opus-20240229",
            cost: 0.05,
            messageId: "test-message",
            requestId: "test-request"
        )
        
        // When - Processing in session calculator
        let calculator = SessionCalculator()
        let sessions = calculator.calculateSessions(from: [opusEntry], plan: .pro)
        
        // Then - Should create active session with Opus
        XCTAssertEqual(sessions.count, 1)
        let session = sessions[0]
        XCTAssertTrue(session.isActive)
        XCTAssertEqual(session.primaryModel, .opus)
        XCTAssertEqual(session.tokenCount, 33) // 25 + 8
    }
    
    func testOpusModelInfo() {
        // Given - Opus model info
        let opusInfo = ModelInfo.opus
        
        // Then - Should have correct properties
        XCTAssertEqual(opusInfo.type, .opus)
        XCTAssertEqual(opusInfo.displayName, "Claude 3 Opus")
        XCTAssertEqual(opusInfo.shortName, "Opus")
        XCTAssertEqual(opusInfo.colorHex, "#EF4444") // Red
        XCTAssertTrue(opusInfo.isHighPerformance)
        XCTAssertEqual(opusInfo.type.tier, 3) // Highest tier
    }
    
    func testEmptyModelStringHandling() {
        // Given - Entry with empty model string (common data issue)
        let emptyModelEntry = createUsageEntry(model: "", inputTokens: 10, outputTokens: 5)
        let opusEntry = createUsageEntry(model: "claude-3-opus-20240229", inputTokens: 100, outputTokens: 50)
        
        // When - Creating session
        let calculator = SessionCalculator()
        let session = calculator.calculateSessions(from: [emptyModelEntry, opusEntry], plan: .pro)[0]
        
        // Then - Should not let empty models hide Opus
        XCTAssertEqual(session.primaryModel, .opus)
        XCTAssertEqual(session.modelUsage[.opus], 150)
        XCTAssertEqual(session.modelUsage[.unknown], 15)
    }
    
    // MARK: - Helper Methods
    
    private func createUsageEntry(model: String, inputTokens: Int, outputTokens: Int, timeOffset: TimeInterval = 0) -> UsageEntry {
        return UsageEntry(
            timestamp: Date().addingTimeInterval(timeOffset),
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: 0,
            cacheReadTokens: 0,
            model: model,
            cost: Double(inputTokens + outputTokens) * 0.001,
            messageId: UUID().uuidString,
            requestId: UUID().uuidString
        )
    }
}