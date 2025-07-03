import SwiftUI
import UserNotifications

struct DebugView: View {
    @EnvironmentObject var usageManager: UsageDataManager
    @State private var debugInfo = ""
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "gauge.high")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("ClaudeRadar Debug")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Testing UI Components")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Refresh") {
                    usageManager.refreshData()
                    updateDebugInfo()
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Menu Bar Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Menu Bar Status")
                            .font(.headline)
                        
                        Text("Menu bar icon should appear after app launch")
                            .font(.body)
                        
                        Button("Force Menu Bar Setup") {
                            NotificationCenter.default.post(name: .setupMenuBar, object: nil)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Current Session Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Session")
                            .font(.headline)
                        
                        if let session = usageManager.currentSession {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tokens: \(session.tokenCount)/\(session.tokenLimit)")
                                Text("Cost: $\(String(format: "%.4f", session.cost))")
                                Text("Active: \(session.isActive ? "Yes" : "No")")
                                if let burnRate = session.burnRate {
                                    Text("Burn Rate: \(String(format: "%.1f", burnRate)) tokens/min")
                                }
                            }
                        } else {
                            Text("No active session found")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Usage Statistics")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Sessions: \(usageManager.usageStatistics.totalSessions)")
                            Text("Total Tokens: \(usageManager.usageStatistics.totalTokensUsed)")
                            Text("Total Cost: $\(String(format: "%.4f", usageManager.usageStatistics.totalCost))")
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Error Messages
                    if let error = usageManager.errorMessage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Errors")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(error)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    // Debug Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debug Information")
                            .font(.headline)
                        
                        Text(debugInfo)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Actions
                    HStack {
                        Button("Export Data") {
                            usageManager.exportData()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Test Notifications") {
                            testNotification()
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .onAppear {
            usageManager.startMonitoring()
            updateDebugInfo()
        }
    }
    
    private func updateDebugInfo() {
        var info = "App Status:\n"
        info += "- Monitoring: \(usageManager.isMonitoring)\n"
        info += "- Last Update: \(usageManager.lastUpdateTime)\n"
        info += "- Recent Sessions: \(usageManager.recentSessions.count)\n"
        
        // Check Claude data directories
        info += "\nClaude Data Paths:\n"
        let paths = [
            "~/.claude/projects",
            "~/.config/claude/projects"
        ]
        
        for path in paths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            let exists = FileManager.default.fileExists(atPath: expandedPath)
            info += "- \(path): \(exists ? "EXISTS" : "NOT FOUND")\n"
            
            if exists {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: expandedPath)
                    let jsonlFiles = contents.filter { $0.hasSuffix(".jsonl") }
                    info += "  └─ JSONL files: \(jsonlFiles.count)\n"
                } catch {
                    info += "  └─ Error reading: \(error.localizedDescription)\n"
                }
            }
        }
        
        debugInfo = info
    }
    
    private func testNotification() {
        print("📱 Test Notification: ClaudeRadar Test - Notification system is working!")
        // TODO: Implement actual notifications in future update
    }
}

extension Notification.Name {
    static let setupMenuBar = Notification.Name("setupMenuBar")
}