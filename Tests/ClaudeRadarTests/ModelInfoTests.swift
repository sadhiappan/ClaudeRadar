import XCTest
@testable import ClaudeRadar

class ModelInfoTests: XCTestCase {
    
    // MARK: - Model Recognition Tests
    
    func testModelRecognitionFromStandardNames() {
        // Test Opus recognition
        XCTAssertEqual(ModelInfo.from("claude-3-opus-20240229").type, .opus)
        XCTAssertEqual(ModelInfo.from("claude-3-opus").type, .opus)
        
        // Test Sonnet recognition  
        XCTAssertEqual(ModelInfo.from("claude-3-5-sonnet-20241022").type, .sonnet)
        XCTAssertEqual(ModelInfo.from("claude-3-sonnet-20240229").type, .sonnet)
        XCTAssertEqual(ModelInfo.from("claude-3-sonnet").type, .sonnet)
        
        // Test Haiku recognition
        XCTAssertEqual(ModelInfo.from("claude-3-haiku-20240307").type, .haiku)
        XCTAssertEqual(ModelInfo.from("claude-3-haiku").type, .haiku)
    }
    
    func testModelRecognitionFromPartialNames() {
        // Should handle partial or abbreviated names
        XCTAssertEqual(ModelInfo.from("opus").type, .opus)
        XCTAssertEqual(ModelInfo.from("sonnet").type, .sonnet)  
        XCTAssertEqual(ModelInfo.from("haiku").type, .haiku)
    }
    
    func testUnknownModelHandling() {
        let unknownModel = ModelInfo.from("claude-4-unknown-model")
        XCTAssertEqual(unknownModel.type, .unknown)
        XCTAssertEqual(unknownModel.displayName, "Unknown Model")
        XCTAssertEqual(unknownModel.shortName, "Unknown")
    }
    
    // MARK: - Model Properties Tests
    
    func testOpusProperties() {
        let opus = ModelInfo.opus
        XCTAssertEqual(opus.type, .opus)
        XCTAssertEqual(opus.displayName, "Claude 3 Opus")
        XCTAssertEqual(opus.shortName, "Opus")
        XCTAssertEqual(opus.colorHex, "#EF4444") // Red
        XCTAssertTrue(opus.isHighPerformance)
    }
    
    func testSonnetProperties() {
        let sonnet = ModelInfo.sonnet
        XCTAssertEqual(sonnet.type, .sonnet)
        XCTAssertEqual(sonnet.displayName, "Claude 3.5 Sonnet")
        XCTAssertEqual(sonnet.shortName, "Sonnet")
        XCTAssertEqual(sonnet.colorHex, "#3B82F6") // Blue
        XCTAssertTrue(sonnet.isHighPerformance)
    }
    
    func testHaikuProperties() {
        let haiku = ModelInfo.haiku
        XCTAssertEqual(haiku.type, .haiku)
        XCTAssertEqual(haiku.displayName, "Claude 3 Haiku")
        XCTAssertEqual(haiku.shortName, "Haiku")
        XCTAssertEqual(haiku.colorHex, "#10B981") // Green
        XCTAssertFalse(haiku.isHighPerformance)
    }
    
    // MARK: - Model Collection Tests
    
    func testAllModelsCollection() {
        let allModels = ModelInfo.allKnownModels
        XCTAssertEqual(allModels.count, 3)
        XCTAssertTrue(allModels.contains { $0.type == .opus })
        XCTAssertTrue(allModels.contains { $0.type == .sonnet })
        XCTAssertTrue(allModels.contains { $0.type == .haiku })
    }
    
    func testModelSorting() {
        let models = ModelInfo.allKnownModels
        // Should be sorted by performance: Opus > Sonnet > Haiku
        XCTAssertEqual(models[0].type, .opus)
        XCTAssertEqual(models[1].type, .sonnet)
        XCTAssertEqual(models[2].type, .haiku)
    }
    
    // MARK: - Edge Cases
    
    func testEmptyStringHandling() {
        let emptyModel = ModelInfo.from("")
        XCTAssertEqual(emptyModel.type, .unknown)
    }
    
    func testCaseInsensitiveMatching() {
        XCTAssertEqual(ModelInfo.from("OPUS").type, .opus)
        XCTAssertEqual(ModelInfo.from("Sonnet").type, .sonnet)
        XCTAssertEqual(ModelInfo.from("HAIKU").type, .haiku)
    }
    
    func testWhitespaceHandling() {
        XCTAssertEqual(ModelInfo.from("  opus  ").type, .opus)
        XCTAssertEqual(ModelInfo.from("\tsonnet\n").type, .sonnet)
    }
}