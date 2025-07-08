import Foundation

class SessionCalculator {
    private let sessionDuration: TimeInterval = 5 * 60 * 60 // 5 hours in seconds
    private let calendar = Calendar.current // Cached calendar instance
    private var modelTypeCache: [String: ModelType] = [:] // Cache model type lookups
    
    func calculateSessions(from entries: [UsageEntry], plan: TokenPlan) -> [ClaudeSession] {
        guard !entries.isEmpty else { return [] }
        
        var sessions: [ClaudeSession] = []
        var currentSessionEntries: [UsageEntry] = []
        var sessionStartTime: Date?
        
        // Group entries into 5-hour sessions
        for entry in entries {
            if let startTime = sessionStartTime {
                let timeSinceStart = entry.timestamp.timeIntervalSince(startTime)
                
                if timeSinceStart <= sessionDuration {
                    // Same session
                    currentSessionEntries.append(entry)
                } else {
                    // New session - process previous session
                    if let session = createSession(from: currentSessionEntries, startTime: startTime, plan: plan) {
                        sessions.append(session)
                    }
                    
                    // Start new session
                    currentSessionEntries = [entry]
                    sessionStartTime = entry.timestamp
                }
            } else {
                // First entry
                currentSessionEntries = [entry]
                sessionStartTime = entry.timestamp
            }
        }
        
        // Process final session
        if let startTime = sessionStartTime,
           let session = createSession(from: currentSessionEntries, startTime: startTime, plan: plan) {
            sessions.append(session)
        }
        
        return sessions.sorted { $0.startTime > $1.startTime } // Most recent first
    }
    
    // MARK: - Hour-Aligned Session Calculation (Python parity)
    
    func calculateHourAlignedSessions(from entries: [UsageEntry], plan: TokenPlan) -> [ClaudeSession] {
        guard !entries.isEmpty else { return [] }
        
        var sessions: [ClaudeSession] = []
        // O(n) grouping using dictionary instead of O(n²) nested loop
        var sessionBlocks: [Date: [UsageEntry]] = [:]
        
        // Group entries into hour-aligned 5-hour blocks
        for entry in entries {
            let alignedStartTime = alignToHour(entry.timestamp)
            sessionBlocks[alignedStartTime, default: []].append(entry)
        }
        
        // Convert blocks to sessions
        for (startTime, entries) in sessionBlocks {
            if let session = createAlignedSession(
                from: entries, 
                startTime: startTime, 
                plan: plan
            ) {
                sessions.append(session)
            }
        }
        
        return sessions.sorted { $0.startTime > $1.startTime } // Most recent first
    }
    
    private func alignToHour(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func getModelType(for model: String) -> ModelType {
        if let cached = modelTypeCache[model] {
            return cached
        }
        let modelType = ModelInfo.from(model).type
        modelTypeCache[model] = modelType
        return modelType
    }
    
    private func createAlignedSession(from entries: [UsageEntry], startTime: Date, plan: TokenPlan) -> ClaudeSession? {
        guard !entries.isEmpty else { return nil }
        
        let sessionId = UUID().uuidString
        let endTime = startTime.addingTimeInterval(sessionDuration)
        
        // Calculate token counts and model usage
        var tokenCounts = TokenCounts()
        var totalCost: Double = 0
        var modelUsage: [ModelType: Int] = [:]
        
        for entry in entries {
            tokenCounts.inputTokens += entry.inputTokens
            tokenCounts.outputTokens += entry.outputTokens
            tokenCounts.cacheCreationTokens += entry.cacheCreationTokens
            tokenCounts.cacheReadTokens += entry.cacheReadTokens
            totalCost += entry.cost
            
            // Track model usage
            let modelType = getModelType(for: entry.model)
            let entryTokens = entry.totalTokens
            modelUsage[modelType, default: 0] += entryTokens
        }
        
        // Determine if session is active
        let now = Date()
        let isActive = now >= startTime && now < endTime
        
        // Calculate burn rate
        let activeDuration = isActive ? now.timeIntervalSince(startTime) : sessionDuration
        let burnRate = calculateBurnRate(entries: entries, sessionDuration: activeDuration)
        
        // Determine token limit
        let tokenLimit = plan == .customMax ? detectTokenLimit(from: entries) : plan.tokenLimit
        
        var session = ClaudeSession(
            id: sessionId,
            startTime: startTime,
            endTime: endTime,
            tokenCount: tokenCounts.totalTokens,
            tokenLimit: tokenLimit,
            cost: totalCost,
            isActive: isActive,
            burnRate: burnRate
        )
        
        // Add model tracking
        session.modelUsage = modelUsage
        
        return session
    }
    
    private func createSession(from entries: [UsageEntry], startTime: Date, plan: TokenPlan) -> ClaudeSession? {
        guard !entries.isEmpty else { return nil }
        
        let sessionId = UUID().uuidString
        let endTime = Date(timeInterval: sessionDuration, since: startTime)
        let _ = entries.last?.timestamp ?? startTime
        
        // Calculate token counts and model usage
        var tokenCounts = TokenCounts()
        var totalCost: Double = 0
        var modelUsage: [ModelType: Int] = [:]
        
        for entry in entries {
            tokenCounts.inputTokens += entry.inputTokens
            tokenCounts.outputTokens += entry.outputTokens
            tokenCounts.cacheCreationTokens += entry.cacheCreationTokens
            tokenCounts.cacheReadTokens += entry.cacheReadTokens
            totalCost += entry.cost
            
            // Track model usage
            let modelType = getModelType(for: entry.model)
            let entryTokens = entry.totalTokens
            modelUsage[modelType, default: 0] += entryTokens
        }
        
        // Determine if session is active
        let now = Date()
        let isActive = now < endTime
        
        // Calculate burn rate
        let burnRate = calculateBurnRate(entries: entries, sessionDuration: min(sessionDuration, now.timeIntervalSince(startTime)))
        
        // Determine token limit
        let tokenLimit = plan == .customMax ? detectTokenLimit(from: entries) : plan.tokenLimit
        
        var session = ClaudeSession(
            id: sessionId,
            startTime: startTime,
            endTime: endTime,
            tokenCount: tokenCounts.totalTokens,
            tokenLimit: tokenLimit,
            cost: totalCost,
            isActive: isActive,
            burnRate: burnRate
        )
        
        // Add model tracking
        session.modelUsage = modelUsage
        
        return session
    }
    
    private func calculateBurnRate(entries: [UsageEntry], sessionDuration: TimeInterval) -> Double? {
        guard !entries.isEmpty, sessionDuration > 0 else { return nil }
        
        let totalTokens = entries.reduce(0) { $0 + $1.totalTokens }
        let durationInMinutes = sessionDuration / 60
        
        return Double(totalTokens) / durationInMinutes
    }
    
    // MARK: - Multi-Session Burn Rate (Python Parity)
    
    func calculateHourlyAggregatedBurnRate(from sessions: [ClaudeSession], currentTime: Date) -> Double? {
        let oneHourAgo = currentTime.addingTimeInterval(-3600) // 1 hour ago
        var totalTokensInLastHour = 0
        var totalMinutesWithActivity = 0.0
        
        for session in sessions {
            // Calculate overlap with the last hour window
            let windowStart = max(session.startTime, oneHourAgo)
            let windowEnd = min(session.endTime, currentTime)
            
            // Skip if no overlap with last hour
            guard windowStart < windowEnd else { continue }
            
            let overlapDuration = windowEnd.timeIntervalSince(windowStart)
            let overlapMinutes = overlapDuration / 60.0
            
            // Calculate proportional tokens for this overlap
            let sessionDuration = session.endTime.timeIntervalSince(session.startTime)
            let proportionalTokens = Double(session.tokenCount) * (overlapDuration / sessionDuration)
            
            totalTokensInLastHour += Int(proportionalTokens)
            totalMinutesWithActivity += overlapMinutes
        }
        
        // Return nil if no activity in last hour
        guard totalMinutesWithActivity > 0 else { return nil }
        
        // Calculate average burn rate across all recent activity
        return Double(totalTokensInLastHour) / totalMinutesWithActivity
    }
    
    private func detectTokenLimit(from entries: [UsageEntry]) -> Int {
        // Try to detect token limit based on usage patterns (Python parity)
        
        let totalTokens = entries.reduce(0) { $0 + $1.totalTokens }
        
        // Estimate based on current usage (updated to match Python limits)
        if totalTokens > 100_000 {
            return 880_000 // Likely Max20
        } else if totalTokens > 25_000 {
            return 220_000   // Likely Max5
        } else {
            return 44_000    // Likely Pro
        }
    }
}

// MARK: - Session Status Calculation

extension ClaudeSession {
    var status: SessionStatus {
        let now = Date()
        
        if !isActive {
            return .expired
        }
        
        let timeRemaining = endTime.timeIntervalSince(now)
        let minutesRemaining = Int(timeRemaining / 60)
        
        if minutesRemaining < 10 {
            return .approaching(remainingMinutes: minutesRemaining)
        }
        
        let percentage = progress * 100
        
        if percentage >= 90 {
            return .critical(percentage: percentage)
        } else if percentage >= 70 {
            return .warning(percentage: percentage)
        } else {
            return .active
        }
    }
}