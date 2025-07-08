import XCTest
@testable import ClaudeRadar

final class NoActiveSessionBugTests: XCTestCase {
    
    // MARK: - TDD Test: Debug "No Active Session" Issue
    
    func testShouldShowActiveSessionInRealEnvironment() async {
        // FAILING TEST: This should pass but currently fails
        // Given - The real app environment with actual Claude data
        let usageManager = UsageDataManager(dataLoader: ClaudeDataLoader())
        
        // When - We load data and check for current session (like the app does)
        await usageManager.loadUsageData()
        
        // Then - Should have an active session (this is what the user expects to see)
        XCTAssertNotNil(usageManager.currentSession, 
            "🚨 FAILING TEST: App shows 'No active session' but should show active session with recent Claude usage")
        
        if let session = usageManager.currentSession {
            XCTAssertTrue(session.isActive, "Session should be active")
            XCTAssertGreaterThan(session.tokenCount, 0, "Session should have token usage")
            print("✅ Found active session: \(session.tokenCount) tokens")
        } else {
            print("❌ No active session found - this reproduces the user's bug")
            print("📊 Recent sessions count: \(usageManager.recentSessions.count)")
            
            // Debug what we actually got
            if !usageManager.recentSessions.isEmpty {
                let mostRecent = usageManager.recentSessions.first!
                print("📅 Most recent session: \(mostRecent.tokenCount) tokens, active: \(mostRecent.isActive)")
                print("📅 Session end time: \(mostRecent.endTime)")
                print("📅 Current time: \(Date())")
            }
        }
    }
    
    func testShouldDetectSessionCalculationIssues() {
        // Given - Sample entries (simulating real data)
        let now = Date()
        let recentEntries = [
            createMockEntry(timestamp: now.addingTimeInterval(-1800), tokens: 1000), // 30 min ago
            createMockEntry(timestamp: now.addingTimeInterval(-900), tokens: 2000),  // 15 min ago
            createMockEntry(timestamp: now.addingTimeInterval(-300), tokens: 1500)   // 5 min ago
        ]
        
        let calculator = SessionCalculator()
        
        // When - We calculate sessions
        let sessions = calculator.calculateSessions(from: recentEntries, plan: .pro)
        
        // Then - Should create at least one session
        print("🎯 Session Calculation Test Results:")
        print("✅ Created \(sessions.count) sessions from \(recentEntries.count) entries")
        
        XCTAssertGreaterThan(sessions.count, 0, "Should create at least one session from recent entries")
        
        // Check for active session
        let activeSessions = sessions.filter { $0.isActive }
        print("⚡ Active sessions: \(activeSessions.count)")
        
        if let activeSession = activeSessions.first {
            print("✅ Active session found: \(activeSession.tokenCount) tokens")
            XCTAssertTrue(activeSession.isActive, "Session should be active")
            XCTAssertGreaterThan(activeSession.tokenCount, 0, "Should have token count")
        } else {
            print("❌ No active session found - debugging:")
            for (index, session) in sessions.enumerated() {
                print("  Session \(index + 1): \(session.tokenCount) tokens, active: \(session.isActive)")
                print("    Start: \(session.startTime), End: \(session.endTime)")
            }
            XCTFail("Should have at least one active session with recent entries")
        }
    }
    
    func testShouldDetectUIBindingIssues() {
        // Given - A mock session that should display
        let mockSession = createMockActiveSession()
        
        // When - We check the layout data
        let layoutData = mockSession.metricsLayoutData
        
        // Then - Should have proper display data
        print("🖥️ UI Binding Test Results:")
        print("✅ Primary display: '\(layoutData.primaryTokenDisplay)'")
        print("✅ Status message: '\(layoutData.statusMessage)'")
        print("✅ Burn rate: '\(layoutData.burnRateDisplay)'")
        print("✅ Time remaining: '\(layoutData.timeRemainingDisplay)'")
        
        XCTAssertFalse(layoutData.primaryTokenDisplay.isEmpty, "Should have token display")
        XCTAssertFalse(layoutData.statusMessage.isEmpty, "Should have status message")
        XCTAssertNotEqual(layoutData.primaryTokenDisplay, "No active session", 
                         "Active session should not show 'No active session'")
    }
    
    func testShouldIdentifyRecentDataProcessingIssue() {
        // Given - Very recent entries (simulating current Claude usage)
        let now = Date()
        let veryRecentEntries = [
            createMockEntry(timestamp: now.addingTimeInterval(-60), tokens: 500),   // 1 min ago
            createMockEntry(timestamp: now.addingTimeInterval(-30), tokens: 300),   // 30 sec ago
            createMockEntry(timestamp: now.addingTimeInterval(-10), tokens: 200)    // 10 sec ago
        ]
        
        let calculator = SessionCalculator()
        
        // When - Calculate sessions with very recent data
        let sessions = calculator.calculateSessions(from: veryRecentEntries, plan: .pro)
        
        // Then - Should handle very recent entries properly
        print("⏱️ Recent Data Processing Test:")
        print("✅ Processed \(veryRecentEntries.count) very recent entries")
        print("✅ Created \(sessions.count) sessions")
        
        let activeSessions = sessions.filter { $0.isActive }
        XCTAssertGreaterThan(activeSessions.count, 0, 
                           "Very recent entries should create active session")
        
        if let activeSession = activeSessions.first {
            print("✅ Active session: \(activeSession.tokenCount) tokens, \(activeSession.isActive)")
            
            // Check if session timing is reasonable
            let sessionAge = now.timeIntervalSince(activeSession.startTime)
            print("📅 Session started \(Int(sessionAge/60)) minutes ago")
            XCTAssertLessThan(sessionAge, 2 * 3600, "Session should be recent (< 2 hours old)")
        }
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
            cost: Double(tokens) * 0.003 / 1000,
            messageId: UUID().uuidString,
            requestId: UUID().uuidString
        )
    }
    
    private func createMockActiveSession() -> ClaudeSession {
        let now = Date()
        return ClaudeSession(
            id: UUID().uuidString,
            startTime: now.addingTimeInterval(-1800), // 30 min ago
            endTime: now.addingTimeInterval(3 * 3600), // 3 hours from now
            tokenCount: 15_000,
            tokenLimit: 44_000,
            cost: 45.0,
            isActive: true,
            burnRate: 50.0
        )
    }
}

// MARK: - Debug Extension for Real Testing

extension ClaudeDataLoader {
    func debugDataPaths() -> [String] {
        let paths = [
            "~/.claude/projects",
            "~/.config/claude/projects"
        ]
        
        print("🔍 Checking data paths:")
        for path in paths {
            let expandedPath = path.expandingTildeInPath
            let exists = FileManager.default.fileExists(atPath: expandedPath)
            print("  \(expandedPath): \(exists ? "✅ EXISTS" : "❌ NOT FOUND")")
        }
        
        return paths
    }
}