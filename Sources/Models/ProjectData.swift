import Foundation
import SwiftUI

// MARK: - Project Usage Data Model

struct ProjectUsage: Identifiable {
    let id: String // Project path
    let name: String // Display name (last path component)
    let fullPath: String // Full project path
    let totalTokens: Int
    let sessionCount: Int
    let lastUsed: Date
    let averageTokensPerSession: Int
    let percentage: Double // Percentage of total usage
    
    // Computed properties
    var displayName: String {
        // Extract meaningful project name from path
        let components = fullPath.components(separatedBy: "/")
        if let codeIndex = components.firstIndex(of: "code"), codeIndex + 1 < components.count {
            return components[codeIndex + 1]
        }
        return name
    }
    
    var formattedTokenCount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: totalTokens)) ?? "\(totalTokens)"
    }
    
    var lastUsedDisplay: String {
        let now = Date()
        let interval = now.timeIntervalSince(lastUsed)
        
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else {
            let minutes = Int(interval / 60)
            return minutes > 0 ? "\(minutes)m ago" : "Just now"
        }
    }
    
    var averageTokensDisplay: String {
        let avg = averageTokensPerSession
        if avg >= 1000 {
            return "\(avg / 1000)k"
        }
        return "\(avg)"
    }
    
    // Consistent color based on project path
    var color: Color {
        ProjectColorGenerator.color(for: fullPath)
    }
}

// MARK: - Project Color Generator

struct ProjectColorGenerator {
    // Predefined color palette for projects
    private static let projectColors: [Color] = [
        Color(red: 0.91, green: 0.30, blue: 0.24), // Red
        Color(red: 0.90, green: 0.49, blue: 0.13), // Orange
        Color(red: 0.18, green: 0.80, blue: 0.44), // Green
        Color(red: 0.20, green: 0.60, blue: 1.00), // Blue
        Color(red: 0.61, green: 0.35, blue: 0.71), // Purple
        Color(red: 0.95, green: 0.77, blue: 0.06), // Yellow
        Color(red: 0.00, green: 0.74, blue: 0.83), // Cyan
        Color(red: 0.90, green: 0.11, blue: 0.39), // Pink
    ]
    
    static func color(for projectPath: String) -> Color {
        // Generate consistent hash from project path
        var hash = 0
        for char in projectPath {
            hash = ((hash << 5) &- hash) &+ Int(char.asciiValue ?? 0)
        }
        
        // Use absolute value and modulo to get index
        let index = abs(hash) % projectColors.count
        return projectColors[index]
    }
}

// MARK: - Project Usage Mock Data (for testing)

extension ProjectUsage {
    static let mockData: [ProjectUsage] = [
        ProjectUsage(
            id: "/Users/shivadhiappan/Documents/code/CapexCapture",
            name: "CapexCapture",
            fullPath: "/Users/shivadhiappan/Documents/code/CapexCapture",
            totalTokens: 660337,
            sessionCount: 20,
            lastUsed: Date().addingTimeInterval(-7200), // 2 hours ago
            averageTokensPerSession: 33000,
            percentage: 44
        ),
        ProjectUsage(
            id: "/Users/shivadhiappan/Documents/code/Usage-Monitor",
            name: "Usage-Monitor",
            fullPath: "/Users/shivadhiappan/Documents/code/Usage-Monitor",
            totalTokens: 195228,
            sessionCount: 7,
            lastUsed: Date().addingTimeInterval(-14400), // 4 hours ago
            averageTokensPerSession: 28000,
            percentage: 13
        ),
        ProjectUsage(
            id: "/Users/shivadhiappan/Documents/code/ClaudeRadar",
            name: "ClaudeRadar",
            fullPath: "/Users/shivadhiappan/Documents/code/ClaudeRadar",
            totalTokens: 87258,
            sessionCount: 6,
            lastUsed: Date(), // Active now
            averageTokensPerSession: 15000,
            percentage: 6
        )
    ]
}