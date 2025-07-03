import Foundation
import AppKit

// MARK: - Timezone Utilities

extension TimeZone {
    static var preferred: TimeZone {
        let identifier = UserDefaults.standard.string(forKey: "preferredTimezone") ?? TimeZone.current.identifier
        return TimeZone(identifier: identifier) ?? TimeZone.current
    }
}

// MARK: - Core Data Models

struct ClaudeSession: Identifiable, Codable {
    let id: String
    let startTime: Date
    let endTime: Date
    var tokenCount: Int
    let tokenLimit: Int
    var cost: Double
    var isActive: Bool
    var burnRate: Double?
    
    // MARK: - Model Tracking
    var modelUsage: [ModelType: Int] = [:]
    
    var primaryModel: ModelType {
        return modelUsage.max(by: { first, second in
            // If token counts are equal, prefer higher tier model
            if first.value == second.value {
                return first.key.tier < second.key.tier
            }
            return first.value < second.value
        })?.key ?? .unknown
    }
    
    var modelBreakdown: [ModelUsageBreakdown] {
        let totalTokens = tokenCount
        guard totalTokens > 0 else { return [] }
        
        return modelUsage.map { (modelType, tokens) in
            let percentage = Double(tokens) / Double(totalTokens) * 100.0
            return ModelUsageBreakdown(
                modelType: modelType,
                tokenCount: tokens,
                percentage: percentage
            )
        }.sorted { $0.tokenCount > $1.tokenCount } // Sort by usage descending
    }
    
    var progress: Double {
        return Double(tokenCount) / Double(tokenLimit)
    }
    
    var remainingTokens: Int {
        return max(0, tokenLimit - tokenCount)
    }
    
    var timeRemaining: TimeInterval? {
        guard let burnRate = burnRate, burnRate > 0 else { return nil }
        let remainingMinutes = Double(remainingTokens) / burnRate // burnRate is already per minute
        return remainingMinutes * 60 // convert to seconds
    }
    
    // MARK: - Predicted End Time (Python Parity)
    
    var predictedEndTime: Date? {
        guard isActive, let burnRate = burnRate, burnRate > 0 else { return nil }
        let remainingMinutes = Double(remainingTokens) / burnRate
        return Date().addingTimeInterval(remainingMinutes * 60)
    }
    
    var predictedEndTimeDisplay: String {
        guard let endTime = predictedEndTime else { return "—" }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    // MARK: - Session End Time
    
    var timeUntilSessionEnd: TimeInterval {
        return max(0, endTime.timeIntervalSince(Date()))
    }
    
    var sessionEndCountdownDisplay: String {
        let seconds = timeUntilSessionEnd
        let totalSeconds = Int(seconds)
        
        if totalSeconds <= 0 {
            return "Expired"
        }
        
        let days = totalSeconds / (24 * 3600)
        let hours = (totalSeconds % (24 * 3600)) / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var sessionEndDisplay: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.preferred
        return formatter.string(from: endTime)
    }
    
    // MARK: - Status Message System (Python Parity)
    
    var statusMessage: String {
        guard isActive else { return "Session expired" }
        
        let usagePercentage = progress * 100
        let currentBurnRate = burnRate ?? 0
        
        // Escalate based on burn rate even if usage is lower
        let isHighBurnRate = currentBurnRate > 100.0 // >100 tokens/min is high
        
        if usagePercentage > 85 {
            return "Limit approaching - slow down"
        } else if usagePercentage > 60 || isHighBurnRate {
            return "High burn rate detected"
        } else if usagePercentage > 30 {
            return "Steady usage pace"
        } else {
            return "Smooth sailing..."
        }
    }
    
    var statusColor: NSColor {
        guard isActive else { return .systemGray }
        
        let usagePercentage = progress * 100
        let currentBurnRate = burnRate ?? 0
        let isHighBurnRate = currentBurnRate > 100.0
        
        if usagePercentage > 85 {
            return .systemRed
        } else if usagePercentage > 60 || isHighBurnRate {
            return .systemOrange
        } else if usagePercentage > 30 {
            return .systemYellow
        } else {
            return .systemGreen
        }
    }
    
    // MARK: - UI Layout Data (TDD)
    
    var metricsLayoutData: MetricsLayoutData {
        if isActive {
            return MetricsLayoutData(
                primaryTokenDisplay: "\(tokenCount) tokens used",
                statusMessage: statusMessage,
                burnRateDisplay: burnRate != nil ? String(format: "%.1f tokens/min", burnRate!) : "—",
                timeRemainingDisplay: formatTimeRemaining(),
                predictedEndDisplay: predictedEndTimeDisplay,
                resetCountdownDisplay: sessionEndCountdownDisplay,
                sessionEndDisplay: sessionEndDisplay,
                usageBarDisplay: "\(tokenCount)/\(tokenLimit)",
                prioritizesKeyMetrics: true
            )
        } else {
            return MetricsLayoutData(
                primaryTokenDisplay: "No active session",
                statusMessage: "Session expired",
                burnRateDisplay: "—",
                timeRemainingDisplay: "—",
                predictedEndDisplay: "—",
                resetCountdownDisplay: "—",
                sessionEndDisplay: "—",
                usageBarDisplay: "\(tokenCount)/\(tokenLimit)",
                prioritizesKeyMetrics: false
            )
        }
    }
    
    private func formatTimeRemaining() -> String {
        guard let timeRemaining = timeRemaining, timeRemaining > 0 else { return "—" }
        
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - UI Layout Data Structure

struct MetricsLayoutData {
    let primaryTokenDisplay: String
    let statusMessage: String
    let burnRateDisplay: String
    let timeRemainingDisplay: String
    let predictedEndDisplay: String
    let resetCountdownDisplay: String
    let sessionEndDisplay: String
    let usageBarDisplay: String
    let prioritizesKeyMetrics: Bool
}

struct UsageEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let inputTokens: Int
    let outputTokens: Int
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let model: String
    let cost: Double
    let messageId: String?
    let requestId: String?
    
    init(timestamp: Date, inputTokens: Int, outputTokens: Int, cacheCreationTokens: Int, cacheReadTokens: Int, model: String, cost: Double, messageId: String?, requestId: String?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.inputTokens = inputTokens
        self.outputTokens = outputTokens
        self.cacheCreationTokens = cacheCreationTokens
        self.cacheReadTokens = cacheReadTokens
        self.model = model
        self.cost = cost
        self.messageId = messageId
        self.requestId = requestId
    }
    
    var totalTokens: Int {
        return inputTokens + outputTokens
    }
    
    var totalCacheTokens: Int {
        return cacheCreationTokens + cacheReadTokens
    }
}

struct TokenCounts: Codable {
    var inputTokens: Int = 0
    var outputTokens: Int = 0
    var cacheCreationTokens: Int = 0
    var cacheReadTokens: Int = 0
    
    var totalTokens: Int {
        return inputTokens + outputTokens
    }
    
    var totalCacheTokens: Int {
        return cacheCreationTokens + cacheReadTokens
    }
}

// MARK: - Enums

enum TokenPlan: String, CaseIterable, Codable {
    case pro = "pro"
    case max5 = "max5"
    case max20 = "max20"
    case customMax = "custom_max"
    
    var displayName: String {
        switch self {
        case .pro: return "Claude Pro"
        case .max5: return "Claude Max 5"
        case .max20: return "Claude Max 20"
        case .customMax: return "Auto-Detect"
        }
    }
    
    var tokenLimit: Int {
        switch self {
        case .pro: return 44_000
        case .max5: return 220_000
        case .max20: return 880_000
        case .customMax: return 0 // Will be determined at runtime
        }
    }
    
    var description: String {
        switch self {
        case .pro: return "~44,000 tokens per 5-hour session"
        case .max5: return "~220,000 tokens per 5-hour session"
        case .max20: return "~880,000 tokens per 5-hour session"
        case .customMax: return "Automatically detect your token limit"
        }
    }
    
    // MARK: - Auto-Detection Logic (Python parity)
    func detectTokenLimit(from sessions: [ClaudeSession]) -> Int {
        guard self == .customMax else { return self.tokenLimit }
        
        // Find the highest token count from completed sessions
        let maxTokens = sessions
            .filter { !$0.isActive } // Only completed sessions
            .map { $0.tokenCount }
            .max() ?? 0
        
        // Detect plan based on usage patterns (matching Python logic)
        if maxTokens > 100_000 {
            return TokenPlan.max20.tokenLimit // 880,000
        } else if maxTokens > 25_000 {
            return TokenPlan.max5.tokenLimit  // 220,000
        } else {
            return TokenPlan.pro.tokenLimit   // 44,000
        }
    }
}

enum SessionStatus {
    case active
    case expired
    case approaching(remainingMinutes: Int)
    case warning(percentage: Double)
    case critical(percentage: Double)
    
    var color: NSColor {
        switch self {
        case .active: return .systemBlue
        case .expired: return .systemGray
        case .approaching: return .systemOrange
        case .warning: return .systemYellow
        case .critical: return .systemRed
        }
    }
    
    var description: String {
        switch self {
        case .active: return "Active"
        case .expired: return "Expired"
        case .approaching(let minutes): return "Expires in \(minutes)m"
        case .warning(let percentage): return "Warning (\(Int(percentage))%)"
        case .critical(let percentage): return "Critical (\(Int(percentage))%)"
        }
    }
}

// MARK: - Usage Statistics

struct UsageStatistics: Codable {
    let totalSessions: Int
    let totalTokensUsed: Int
    let totalCost: Double
    let averageTokensPerSession: Int
    let averageCostPerSession: Double
    let peakUsageDay: Date?
    let currentStreak: Int
    
    static let empty = UsageStatistics(
        totalSessions: 0,
        totalTokensUsed: 0,
        totalCost: 0.0,
        averageTokensPerSession: 0,
        averageCostPerSession: 0.0,
        peakUsageDay: nil,
        currentStreak: 0
    )
}

// MARK: - Notification Models

struct NotificationData {
    let title: String
    let body: String
    let type: NotificationType
    let timestamp: Date
}

enum NotificationType {
    case tokenWarning
    case sessionExpiry
    case burnRateHigh
    case limitExceeded
    case systemError
    
    var icon: String {
        switch self {
        case .tokenWarning: return "exclamationmark.triangle"
        case .sessionExpiry: return "clock"
        case .burnRateHigh: return "flame"
        case .limitExceeded: return "stop.circle"
        case .systemError: return "xmark.circle"
        }
    }
}