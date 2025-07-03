import Foundation
import OSLog
import os.signpost

// MARK: - Protocol for Dependency Injection
protocol DataLoading {
    func loadUsageEntries(from path: String?) async throws -> [UsageEntry]
}

class ClaudeDataLoader: DataLoading {
    private let fileManager = FileManager.default
    private let maxFileSize: Int = 100_000_000 // 100MB limit
    
    // Performance logging
    private let performanceLog = OSLog(subsystem: "com.app.ClaudeRadar", category: .pointsOfInterest)
    private let logger = Logger(subsystem: "com.app.ClaudeRadar", category: "data-loader")
    
    func loadUsageEntries(from customPath: String? = nil) async throws -> [UsageEntry] {
        let signpostID = OSSignpostID(log: performanceLog)
        os_signpost(.begin, log: performanceLog, name: "LoadUsageData", signpostID: signpostID)
        logger.info("🔍 Starting data load from paths")
        
        let claudePaths = customPath != nil ? [customPath!] : getClaudeDataPaths()
        print("🔍 Checking paths: \(claudePaths)")
        
        var allEntries: [UsageEntry] = []
        var processedHashes = Set<String>()
        
        for path in claudePaths {
            let pathURL = URL(fileURLWithPath: path.expandingTildeInPath)
            print("📂 Checking path: \(pathURL.path)")
            
            guard fileManager.fileExists(atPath: pathURL.path) else {
                print("❌ Path does not exist: \(pathURL.path)")
                continue
            }
            
            print("✅ Path exists: \(pathURL.path)")
            let entries = try await loadEntriesFromPath(pathURL, processedHashes: &processedHashes)
            print("📊 Loaded \(entries.count) entries from \(pathURL.path)")
            allEntries.append(contentsOf: entries)
        }
        
        print("📈 Total entries loaded: \(allEntries.count)")
        logger.info("📈 Completed data load: \(allEntries.count) entries")
        os_signpost(.end, log: performanceLog, name: "LoadUsageData", signpostID: signpostID)
        
        // Sort by timestamp
        return allEntries.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func getClaudeDataPaths() -> [String] {
        return [
            "~/.claude/projects",
            "~/.config/claude/projects"
        ]
    }
    
    private func loadEntriesFromPath(_ pathURL: URL, processedHashes: inout Set<String>) async throws -> [UsageEntry] {
        let jsonlFiles = try findJSONLFilesRecursively(in: pathURL)
        print("📁 Found \(jsonlFiles.count) JSONL files recursively in \(pathURL.path)")
        
        var entries: [UsageEntry] = []
        
        for fileURL in jsonlFiles {
            let fileEntries = try await parseJSONLFile(fileURL, processedHashes: &processedHashes)
            entries.append(contentsOf: fileEntries)
        }
        
        return entries
    }
    
    private func findJSONLFilesRecursively(in directory: URL) throws -> [URL] {
        var jsonlFiles: [URL] = []
        
        let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .isRegularFileKey]
        let directoryEnumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: resourceKeys, options: [.skipsHiddenFiles])
        
        while let url = directoryEnumerator?.nextObject() as? URL {
            let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
            
            if resourceValues.isRegularFile == true && url.pathExtension == "jsonl" {
                // Check file size for security
                do {
                    let fileSize = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    if fileSize > maxFileSize {
                        print("⚠️ Skipping large file (\(fileSize) bytes): \(url.lastPathComponent)")
                        continue
                    }
                    jsonlFiles.append(url)
                } catch {
                    print("❌ Could not get file size for: \(url.lastPathComponent)")
                    continue
                }
            }
        }
        
        return jsonlFiles
    }
    
    private func parseJSONLFile(_ fileURL: URL, processedHashes: inout Set<String>) async throws -> [UsageEntry] {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        var entries: [UsageEntry] = []
        
        for line in lines {
            guard let data = line.data(using: .utf8) else { continue }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let json = json else { continue }
                
                // Create unique hash for deduplication
                let uniqueHash = createUniqueHash(from: json)
                if let hash = uniqueHash, processedHashes.contains(hash) {
                    continue // Skip duplicate
                }
                
                if let entry = parseUsageEntry(from: json) {
                    entries.append(entry)
                    if let hash = uniqueHash {
                        processedHashes.insert(hash)
                    }
                }
            } catch {
                // Skip invalid JSON lines
                continue
            }
        }
        
        return entries
    }
    
    private func createUniqueHash(from json: [String: Any]) -> String? {
        var messageId: String?
        var requestId: String?
        
        // Extract message ID
        if let message = json["message"] as? [String: Any] {
            messageId = message["id"] as? String
        } else {
            messageId = json["message_id"] as? String
        }
        
        // Extract request ID
        requestId = json["requestId"] as? String ?? json["request_id"] as? String
        
        guard let msgId = messageId, let reqId = requestId else {
            return nil
        }
        
        return "\(msgId):\(reqId)"
    }
    
    private func parseUsageEntry(from json: [String: Any]) -> UsageEntry? {
        guard let timestampString = json["timestamp"] as? String else { return nil }
        
        // Parse timestamp
        let timestamp: Date
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: timestampString) {
            timestamp = date
        } else {
            return nil
        }
        
        // Extract usage data
        var usage: [String: Any] = [:]
        if let usageData = json["usage"] as? [String: Any] {
            usage = usageData
        } else if let message = json["message"] as? [String: Any],
                  let messageUsage = message["usage"] as? [String: Any] {
            usage = messageUsage
        }
        
        let inputTokens = usage["input_tokens"] as? Int ?? 0
        let outputTokens = usage["output_tokens"] as? Int ?? 0
        let cacheCreationTokens = usage["cache_creation_input_tokens"] as? Int ?? 0
        let cacheReadTokens = usage["cache_read_input_tokens"] as? Int ?? 0
        
        // Extract model
        var model = ""
        if let jsonModel = json["model"] as? String {
            model = jsonModel
        } else if let message = json["message"] as? [String: Any],
                  let messageModel = message["model"] as? String {
            model = messageModel
        }
        
        // Calculate cost (simplified - you might want to implement proper cost calculation)
        let cost = json["cost"] as? Double ?? json["costUSD"] as? Double ?? 0.0
        
        // Extract IDs
        let messageId = json["message_id"] as? String ?? (json["message"] as? [String: Any])?["id"] as? String
        let requestId = json["request_id"] as? String ?? json["requestId"] as? String
        
        return UsageEntry(
            timestamp: timestamp,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens,
            model: model,
            cost: cost,
            messageId: messageId,
            requestId: requestId
        )
    }
}

// MARK: - String Extension

extension String {
    var expandingTildeInPath: String {
        return NSString(string: self).expandingTildeInPath
    }
}