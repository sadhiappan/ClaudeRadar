import Foundation
import SwiftUI

// MARK: - Model Type Enumeration

enum ModelType: String, CaseIterable, Codable {
    case opus = "opus"
    case sonnet = "sonnet" 
    case haiku = "haiku"
    case unknown = "unknown"
    
    var tier: Int {
        switch self {
        case .opus: return 3      // Highest tier
        case .sonnet: return 2    // Mid tier
        case .haiku: return 1     // Fast tier
        case .unknown: return 0   // Unknown tier
        }
    }
}

// MARK: - Model Information Structure

struct ModelInfo: Identifiable, Codable {
    let id: String
    let type: ModelType
    let displayName: String
    let shortName: String
    let colorHex: String
    let isHighPerformance: Bool
    let dailyLimit: Int  // Daily token limit for this model
    
    init(type: ModelType, displayName: String, shortName: String, colorHex: String, dailyLimit: Int, isHighPerformance: Bool = false) {
        self.id = type.rawValue
        self.type = type
        self.displayName = displayName
        self.shortName = shortName
        self.colorHex = colorHex
        self.dailyLimit = dailyLimit
        self.isHighPerformance = isHighPerformance
    }
    
    // MARK: - Color Support
    
    var color: Color {
        return Color(hex: colorHex) ?? Color.gray
    }
    
    // MARK: - Predefined Models
    
    static let opus = ModelInfo(
        type: .opus,
        displayName: "Claude 3 Opus",
        shortName: "Opus",
        colorHex: "#EF4444", // Red
        dailyLimit: 3000,
        isHighPerformance: true
    )
    
    static let sonnet = ModelInfo(
        type: .sonnet,
        displayName: "Claude 3.5 Sonnet",
        shortName: "Sonnet", 
        colorHex: "#3B82F6", // Blue
        dailyLimit: 40000,
        isHighPerformance: true
    )
    
    static let haiku = ModelInfo(
        type: .haiku,
        displayName: "Claude 3 Haiku",
        shortName: "Haiku",
        colorHex: "#10B981", // Green
        dailyLimit: 100000,
        isHighPerformance: false
    )
    
    static let unknown = ModelInfo(
        type: .unknown,
        displayName: "Unknown Model",
        shortName: "Unknown",
        colorHex: "#6B7280", // Gray
        dailyLimit: 0,
        isHighPerformance: false
    )
    
    // MARK: - Model Collection
    
    static let allKnownModels: [ModelInfo] = [opus, sonnet, haiku]
        .sorted { $0.type.tier > $1.type.tier } // Sort by tier (Opus > Sonnet > Haiku)
    
    // MARK: - Model Recognition
    
    static func from(_ modelString: String) -> ModelInfo {
        let normalized = modelString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct type matching - check specific models first
        if normalized.contains("opus") {
            return opus
        }
        if normalized.contains("sonnet") {
            return sonnet
        }
        if normalized.contains("haiku") {
            return haiku
        }
        
        // Fallback patterns for edge cases
        if normalized.contains("claude-3-5") {
            return sonnet
        }
        if normalized.contains("claude-3") {
            // This should rarely be reached due to direct matching above
            return sonnet // Default Claude 3 to Sonnet if no specific match
        }
        
        // Check for specific model IDs
        if normalized.contains("20241022") || normalized.contains("20240620") {
            return sonnet
        }
        
        // Fallback for unknown models (empty strings, etc.)
        return unknown
    }
}

// MARK: - Model Usage Breakdown

struct ModelUsageBreakdown: Identifiable {
    let id = UUID()
    let modelType: ModelType
    let tokenCount: Int
    let percentage: Double  // Percentage of overall session
    
    var modelInfo: ModelInfo {
        switch modelType {
        case .opus: return ModelInfo.opus
        case .sonnet: return ModelInfo.sonnet
        case .haiku: return ModelInfo.haiku
        case .unknown: return ModelInfo.unknown
        }
    }
    
    // Per-model progress (percentage of this model's daily limit)
    var modelProgress: Double {
        guard modelInfo.dailyLimit > 0 else { return 0.0 }
        return min(Double(tokenCount) / Double(modelInfo.dailyLimit), 1.0)
    }
    
    // Tokens remaining for this model
    var tokensRemaining: Int {
        return max(modelInfo.dailyLimit - tokenCount, 0)
    }
    
    // Percentage of model's daily limit used
    var modelLimitPercentage: Double {
        return modelProgress * 100.0
    }
    
    // Formatted display for per-model usage
    var modelUsageDisplay: String {
        return "\(tokenCount) / \(modelInfo.dailyLimit)"
    }
    
    // Formatted display for percentage of model limit
    var modelLimitDisplay: String {
        return "\(Int(modelLimitPercentage.rounded()))% of limit"
    }
    
    // Formatted display for tokens remaining
    var tokensRemainingDisplay: String {
        return "\(tokensRemaining.formatted()) left"
    }
}

// MARK: - Color Extension for Hex Support

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}