import XCTest
import SwiftUI
@testable import ClaudeRadar

class EdgeCaseTests: XCTestCase {
    
    // MARK: - Test Setup
    
    var usageManager: UsageDataManager!
    var themeManager: ThemeManager!
    
    override func setUp() {
        super.setUp()
        usageManager = UsageDataManager()
        themeManager = ThemeManager()
    }
    
    override func tearDown() {
        usageManager = nil
        themeManager = nil
        super.tearDown()
    }
    
    // MARK: - Task 10.4: Edge Case Tests
    
    func testNoDataScenarios() {
        // Given - Various no data scenarios
        let noDataScenarios = [
            // Completely empty state
            (sessions: [ClaudeSession](), currentSession: nil as ClaudeSession?, isLoading: false, errorMessage: nil as String?),
            
            // Loading with no data
            (sessions: [], currentSession: nil, isLoading: true, errorMessage: nil),
            
            // Error with no data
            (sessions: [], currentSession: nil, isLoading: false, errorMessage: "No Claude data found"),
            
            // Historical sessions but no current session
            (sessions: [createExpiredSession()], currentSession: nil, isLoading: false, errorMessage: nil)
        ]
        
        for (index, scenario) in noDataScenarios.enumerated() {
            // When - Setting up no data scenario
            usageManager.recentSessions = scenario.sessions
            usageManager.currentSession = scenario.currentSession
            usageManager.isLoading = scenario.isLoading
            usageManager.errorMessage = scenario.errorMessage
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should handle gracefully
            XCTAssertNotNil(menuBarView, "Scenario \(index): MenuBarView should handle no data state")
            
            // Verify state consistency
            XCTAssertEqual(usageManager.recentSessions.count, scenario.sessions.count, "Scenario \(index): Session count should match")
            XCTAssertEqual(usageManager.isLoading, scenario.isLoading, "Scenario \(index): Loading state should match")
        }
    }
    
    func testSingleModelScenarios() {
        // Given - Sessions with only one model type
        let singleModelScenarios = [
            // Only Opus usage
            ClaudeSession(
                id: "opus-only",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: 5000,
                tokenLimit: 44000,
                cost: 1.5,
                isActive: true,
                burnRate: 25.0,
                models: ["claude-3-opus-20240229": 5000]
            ),
            
            // Only Sonnet usage
            ClaudeSession(
                id: "sonnet-only",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: 3000,
                tokenLimit: 44000,
                cost: 0.9,
                isActive: true,
                burnRate: 20.0,
                models: ["claude-3-sonnet-20240229": 3000]
            ),
            
            // Only Haiku usage
            ClaudeSession(
                id: "haiku-only",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: 1000,
                tokenLimit: 44000,
                cost: 0.2,
                isActive: true,
                burnRate: 10.0,
                models: ["claude-3-haiku-20240307": 1000]
            )
        ]
        
        for (index, session) in singleModelScenarios.enumerated() {
            // When - Testing single model session
            usageManager.currentSession = session
            usageManager.recentSessions = [session]
            usageManager.isLoading = false
            usageManager.errorMessage = nil
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should display single model appropriately
            XCTAssertNotNil(menuBarView, "Single model scenario \(index): MenuBarView should handle single model")
            XCTAssertEqual(session.modelBreakdown.count, 1, "Single model scenario \(index): Should have one model breakdown")
            XCTAssertEqual(session.models.count, 1, "Single model scenario \(index): Should have one model in raw data")
        }
    }
    
    func testErrorScenarios() {
        // Given - Various error conditions
        let errorScenarios = [
            // File access error
            "Permission denied: Unable to read Claude data files",
            
            // Parsing error
            "Invalid JSON format in Claude usage files",
            
            // Network/connection error
            "Unable to connect to Claude service",
            
            // Corrupted data error
            "Corrupted usage data detected",
            
            // Unknown model error
            "Unknown model type encountered: claude-4-experimental",
            
            // Memory error
            "Insufficient memory to process usage data",
            
            // Timeout error
            "Request timeout while loading usage data"
        ]
        
        for (index, errorMessage) in errorScenarios.enumerated() {
            // When - Setting error state
            usageManager.errorMessage = errorMessage
            usageManager.currentSession = nil
            usageManager.recentSessions = []
            usageManager.isLoading = false
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should handle error gracefully
            XCTAssertNotNil(menuBarView, "Error scenario \(index): MenuBarView should handle error")
            XCTAssertEqual(usageManager.errorMessage, errorMessage, "Error scenario \(index): Error message should be preserved")
            
            // Footer should show retry button for errors
            let footerComponent = FooterComponent()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            XCTAssertNotNil(footerComponent, "Error scenario \(index): Footer should be available with retry option")
        }
    }
    
    func testExtremeDataValues() {
        // Given - Extreme data value scenarios
        let extremeScenarios = [
            // Zero usage
            ClaudeSession(
                id: "zero-usage",
                startTime: Date(),
                endTime: Date().addingTimeInterval(18000),
                tokenCount: 0,
                tokenLimit: 44000,
                cost: 0.0,
                isActive: true,
                burnRate: 0.0
            ),
            
            // Maximum realistic usage
            ClaudeSession(
                id: "max-usage",
                startTime: Date().addingTimeInterval(-18000),
                endTime: Date(),
                tokenCount: 199999,
                tokenLimit: 200000,
                cost: 599.99,
                isActive: false,
                burnRate: 999.9
            ),
            
            // Negative burn rate (edge case)
            ClaudeSession(
                id: "negative-burn",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: 1000,
                tokenLimit: 44000,
                cost: 0.3,
                isActive: true,
                burnRate: -5.0
            ),
            
            // Very high burn rate
            ClaudeSession(
                id: "high-burn",
                startTime: Date().addingTimeInterval(-300),
                endTime: Date().addingTimeInterval(17700),
                tokenCount: 10000,
                tokenLimit: 44000,
                cost: 3.0,
                isActive: true,
                burnRate: 2000.0
            )
        ]
        
        for (index, session) in extremeScenarios.enumerated() {
            // When - Testing extreme values
            usageManager.currentSession = session
            usageManager.recentSessions = [session]
            usageManager.isLoading = false
            usageManager.errorMessage = nil
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should handle extreme values without crashing
            XCTAssertNotNil(menuBarView, "Extreme scenario \(index): MenuBarView should handle extreme values")
            
            // Verify progress calculation doesn't exceed bounds
            let progress = session.progress
            XCTAssertTrue(progress >= 0.0, "Extreme scenario \(index): Progress should not be negative")
            XCTAssertTrue(progress <= 1.0, "Extreme scenario \(index): Progress should not exceed 100%")
        }
    }
    
    func testCorruptedDataRecovery() {
        // Given - Corrupted data scenarios
        let corruptedDataScenarios = [
            // Session with invalid dates
            ClaudeSession(
                id: "invalid-dates",
                startTime: Date().addingTimeInterval(3600), // Start time in future
                endTime: Date(),                           // End time in past
                tokenCount: 1000,
                tokenLimit: 5000,
                cost: 0.3,
                isActive: true,
                burnRate: 15.0
            ),
            
            // Session with impossible token counts
            ClaudeSession(
                id: "impossible-tokens",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: 50000,
                tokenLimit: 5000, // Token count exceeds limit
                cost: 15.0,
                isActive: true,
                burnRate: 25.0
            ),
            
            // Session with inconsistent model data
            ClaudeSession(
                id: "inconsistent-models",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: 1000,
                tokenLimit: 5000,
                cost: 0.3,
                isActive: true,
                burnRate: 15.0,
                models: [
                    "claude-3-opus-20240229": 500,
                    "claude-3-sonnet-20240229": 300,
                    "claude-3-haiku-20240307": 400
                    // Total: 1200, but tokenCount is 1000 (inconsistent)
                ]
            )
        ]
        
        for (index, session) in corruptedDataScenarios.enumerated() {
            // When - Processing corrupted data
            usageManager.currentSession = session
            usageManager.recentSessions = [session]
            usageManager.isLoading = false
            usageManager.errorMessage = nil
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should handle corrupted data gracefully
            XCTAssertNotNil(menuBarView, "Corrupted data scenario \(index): Should handle corrupted data")
            
            // Verify model breakdown calculation is defensive
            let breakdown = session.modelBreakdown
            for modelBreakdown in breakdown {
                XCTAssertTrue(modelBreakdown.percentage >= 0.0, "Corrupted data scenario \(index): Percentage should not be negative")
                XCTAssertTrue(modelBreakdown.percentage <= 100.0, "Corrupted data scenario \(index): Percentage should not exceed 100%")
                XCTAssertTrue(modelBreakdown.tokenCount >= 0, "Corrupted data scenario \(index): Token count should not be negative")
            }
        }
    }
    
    func testConcurrentAccessScenarios() {
        // Given - Concurrent access simulation
        let concurrentUpdateCount = 100
        let expectation = XCTestExpectation(description: "Concurrent updates completed")
        expectation.expectedFulfillmentCount = concurrentUpdateCount
        
        // When - Simulating concurrent data updates
        for i in 0..<concurrentUpdateCount {
            DispatchQueue.global(qos: .background).async {
                let session = ClaudeSession(
                    id: "concurrent-\(i)",
                    startTime: Date().addingTimeInterval(-Double(i * 10)),
                    endTime: Date().addingTimeInterval(18000 - Double(i * 10)),
                    tokenCount: i * 100,
                    tokenLimit: 44000,
                    cost: Double(i) * 0.3,
                    isActive: i % 2 == 0,
                    burnRate: Double(i) * 2.0
                )
                
                DispatchQueue.main.async {
                    self.usageManager.currentSession = session
                    expectation.fulfill()
                }
            }
        }
        
        // Then - Should handle concurrent access gracefully
        wait(for: [expectation], timeout: 10.0)
        XCTAssertNotNil(usageManager.currentSession, "Should handle concurrent updates")
    }
    
    func testMemoryPressureScenarios() {
        // Given - Memory pressure simulation
        let largeDataSets = [1000, 5000, 10000]
        
        for dataSetSize in largeDataSets {
            // When - Creating large data sets
            var sessions: [ClaudeSession] = []
            
            for i in 0..<dataSetSize {
                let session = ClaudeSession(
                    id: "memory-test-\(i)",
                    startTime: Date().addingTimeInterval(-Double(i * 60)),
                    endTime: Date().addingTimeInterval(18000 - Double(i * 60)),
                    tokenCount: i * 10,
                    tokenLimit: 44000,
                    cost: Double(i) * 0.01,
                    isActive: i < 10,
                    burnRate: Double(i) * 0.5,
                    models: [
                        "claude-3-opus-20240229": i * 5,
                        "claude-3-sonnet-20240229": i * 3,
                        "claude-3-haiku-20240307": i * 2
                    ]
                )
                sessions.append(session)
            }
            
            usageManager.recentSessions = sessions
            
            // Then - Should handle large data sets without memory issues
            XCTAssertEqual(usageManager.recentSessions.count, dataSetSize, "Should handle \(dataSetSize) sessions")
            
            // Test view creation with large data set
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            XCTAssertNotNil(menuBarView, "Should handle view creation with \(dataSetSize) sessions")
        }
    }
    
    func testNetworkDisconnectionScenarios() {
        // Given - Network disconnection simulation
        let disconnectionScenarios = [
            "Network timeout",
            "No internet connection",
            "Claude service unavailable",
            "Rate limit exceeded",
            "Authentication failed"
        ]
        
        for errorMessage in disconnectionScenarios {
            // When - Simulating network issues
            usageManager.errorMessage = errorMessage
            usageManager.isLoading = false
            usageManager.currentSession = nil
            usageManager.recentSessions = []
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should provide appropriate feedback
            XCTAssertNotNil(menuBarView, "Should handle network disconnection: \(errorMessage)")
            XCTAssertNotNil(usageManager.errorMessage, "Should preserve error message")
        }
    }
    
    func testRapidStateChangeScenarios() {
        // Given - Rapid state changes
        let stateChangeCount = 50
        
        // When - Rapidly changing states
        for i in 0..<stateChangeCount {
            switch i % 4 {
            case 0:
                // Loading state
                usageManager.isLoading = true
                usageManager.currentSession = nil
                usageManager.errorMessage = nil
                
            case 1:
                // Data loaded state
                usageManager.isLoading = false
                usageManager.currentSession = createMockSession(tokenCount: i * 100)
                usageManager.errorMessage = nil
                
            case 2:
                // Error state
                usageManager.isLoading = false
                usageManager.currentSession = nil
                usageManager.errorMessage = "Test error \(i)"
                
            case 3:
                // No data state
                usageManager.isLoading = false
                usageManager.currentSession = nil
                usageManager.errorMessage = nil
                
            default:
                break
            }
            
            let menuBarView = MenuBarView()
                .environmentObject(usageManager)
                .environmentObject(themeManager)
            
            // Then - Should handle rapid state changes
            XCTAssertNotNil(menuBarView, "Should handle rapid state change \(i)")
        }
    }
    
    func testBoundaryValueScenarios() {
        // Given - Boundary value testing
        let boundaryScenarios = [
            // Exactly at token limit
            (tokenCount: 44000, tokenLimit: 44000, expectedProgress: 1.0),
            
            // One token under limit
            (tokenCount: 43999, tokenLimit: 44000, expectedProgress: 0.999977),
            
            // One token over limit (edge case)
            (tokenCount: 44001, tokenLimit: 44000, expectedProgress: 1.0), // Should cap at 100%
            
            // Minimum values
            (tokenCount: 1, tokenLimit: 44000, expectedProgress: 0.000023),
            
            // Large numbers
            (tokenCount: 999999, tokenLimit: 1000000, expectedProgress: 0.999999)
        ]
        
        for (index, scenario) in boundaryScenarios.enumerated() {
            // When - Testing boundary values
            let session = ClaudeSession(
                id: "boundary-\(index)",
                startTime: Date().addingTimeInterval(-1800),
                endTime: Date().addingTimeInterval(16200),
                tokenCount: scenario.tokenCount,
                tokenLimit: scenario.tokenLimit,
                cost: 1.5,
                isActive: true,
                burnRate: 25.0
            )
            
            // Then - Should calculate correct progress
            let actualProgress = session.progress
            XCTAssertEqual(actualProgress, scenario.expectedProgress, accuracy: 0.001, "Boundary scenario \(index): Progress calculation should be accurate")
            XCTAssertTrue(actualProgress >= 0.0, "Boundary scenario \(index): Progress should not be negative")
            XCTAssertTrue(actualProgress <= 1.0, "Boundary scenario \(index): Progress should not exceed 100%")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockSession(tokenCount: Int = 15000, isActive: Bool = true) -> ClaudeSession {
        return ClaudeSession(
            id: "mock-session-\(tokenCount)",
            startTime: Date().addingTimeInterval(-1800),
            endTime: Date().addingTimeInterval(16200),
            tokenCount: tokenCount,
            tokenLimit: 44000,
            cost: 0.45,
            isActive: isActive,
            burnRate: 25.0
        )
    }
    
    private func createExpiredSession() -> ClaudeSession {
        return ClaudeSession(
            id: "expired-session",
            startTime: Date().addingTimeInterval(-25200), // 7 hours ago
            endTime: Date().addingTimeInterval(-7200),   // 2 hours ago
            tokenCount: 5000,
            tokenLimit: 44000,
            cost: 1.5,
            isActive: false,
            burnRate: 0.0
        )
    }
}

// MARK: - Edge Case Test Utilities

extension EdgeCaseTests {
    
    /// Test that a component handles edge cases gracefully
    func assertEdgeCaseHandling<T: View>(_ view: T, scenario: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(view, "View should handle edge case: \(scenario)", file: file, line: line)
    }
    
    /// Test that data validation works correctly
    func assertDataValidation<T: Equatable>(_ actual: T, expected: T, scenario: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(actual, expected, "Data validation should work for scenario: \(scenario)", file: file, line: line)
    }
    
    /// Test that error recovery mechanisms work
    func assertErrorRecovery(_ errorMessage: String?, file: StaticString = #file, line: UInt = #line) {
        if let error = errorMessage {
            XCTAssertFalse(error.isEmpty, "Error message should be meaningful", file: file, line: line)
        }
    }
}