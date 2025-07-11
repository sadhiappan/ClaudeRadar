import Foundation
import OSLog
import os.signpost

// MARK: - Security Error Types

enum SecurityError: Error, LocalizedError {
    case pathTraversalAttempt
    case invalidPath
    case memoryBudgetExceeded
    
    var errorDescription: String? {
        switch self {
        case .pathTraversalAttempt:
            return "Path traversal attempt detected"
        case .invalidPath:
            return "Invalid or unsafe path provided"
        case .memoryBudgetExceeded:
            return "Memory budget exceeded"
        }
    }
}

// MARK: - Protocol for Dependency Injection
protocol DataLoading {
    func loadUsageEntries(from path: String?) async throws -> [UsageEntry]
}

class ClaudeDataLoader: DataLoading {
    private let fileManager = FileManager.default
    private let maxFileSize: Int = 100_000_000 // 100MB limit
    
    // Memory budget management for security
    private let maxTotalMemoryUsage: Int = 500_000_000 // 500MB total budget
    private var currentMemoryUsage: Int = 0
    
    // Performance logging
    private let performanceLog = OSLog(subsystem: "com.app.ClaudeRadar", category: .pointsOfInterest)
    private let logger = Logger(subsystem: "com.app.ClaudeRadar", category: "data-loader")
    
    func loadUsageEntries(from customPath: String? = nil) async throws -> [UsageEntry] {
        let signpostID = OSSignpostID(log: performanceLog)
        os_signpost(.begin, log: performanceLog, name: "LoadUsageData", signpostID: signpostID)
        logger.info("🔍 Starting data load from paths")
        
        // Reset memory tracking for each load operation
        resetMemoryTracking()
        
        // Determine paths to process with security validation
        let claudePaths: [String]
        if let customPath = customPath {
            // Validate custom path for security
            do {
                let validatedURL = try validateClaudePath(customPath)
                claudePaths = [validatedURL.path]
                logger.info("✅ Using validated custom path: \(validatedURL.path)")
            } catch {
                logger.warning("⚠️ Custom path validation failed, falling back to defaults: \(error.localizedDescription)")
                claudePaths = getClaudeDataPaths()
            }
        } else {
            // Use default paths (already trusted)
            claudePaths = getClaudeDataPaths()
        }
        
        print("🔍 Checking paths: \(claudePaths)")
        
        var allEntries: [UsageEntry] = []
        var processedHashes = Set<String>()
        
        for path in claudePaths {
            // For default paths, use original logic; custom paths already validated
            let pathURL: URL
            if customPath != nil && claudePaths.first == path {
                // This is our validated custom path
                pathURL = URL(fileURLWithPath: path)
            } else {
                // This is a default path
                pathURL = URL(fileURLWithPath: path.expandingTildeInPath)
            }
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
    
    // MARK: - Memory Budget Management
    
    private func checkMemoryBudget(for fileSize: Int) -> Bool {
        let wouldExceedBudget = currentMemoryUsage + fileSize > maxTotalMemoryUsage
        if wouldExceedBudget {
            logger.warning("⚠️ Memory budget would be exceeded. Current: \(self.currentMemoryUsage), File: \(fileSize), Budget: \(self.maxTotalMemoryUsage)")
        }
        return !wouldExceedBudget
    }
    
    private func trackMemoryUsage(adding fileSize: Int) {
        currentMemoryUsage += fileSize
        logger.debug("📊 Memory usage: \(self.currentMemoryUsage)/\(self.maxTotalMemoryUsage) bytes (\(Int(Double(self.currentMemoryUsage)/Double(self.maxTotalMemoryUsage)*100))%)")
    }
    
    private func resetMemoryTracking() {
        currentMemoryUsage = 0
        logger.debug("🔄 Memory tracking reset")
    }
    
    // MARK: - Path Validation for Security
    
    private func validateClaudePath(_ path: String) throws -> URL {
        let expanded = path.expandingTildeInPath
        let url = URL(fileURLWithPath: expanded).resolvingSymlinksInPath()
        
        // Define allowed path prefixes for Claude data
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let allowedPrefixes = [
            homeDirectory.appendingPathComponent(".claude"),
            homeDirectory.appendingPathComponent(".config/claude")
        ]
        
        // Check if the resolved path starts with any allowed prefix
        guard allowedPrefixes.contains(where: { url.path.hasPrefix($0.path) }) else {
            logger.error("🚨 Path traversal attempt detected: \(path) -> \(url.path)")
            throw SecurityError.pathTraversalAttempt
        }
        
        logger.debug("✅ Path validation passed: \(url.path)")
        return url
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
        
        // Process files sequentially (concurrent processing with mutable state is complex)
        // TODO: Implement proper concurrent processing with actor-based deduplication
        var entries: [UsageEntry] = []
        
        for fileURL in jsonlFiles {
            let fileEntries = try await parseJSONLFile(fileURL, processedHashes: &processedHashes, basePath: pathURL)
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
                    
                    // Check memory budget before adding file
                    if !checkMemoryBudget(for: fileSize) {
                        logger.warning("⚠️ Skipping file due to memory budget: \(url.lastPathComponent) (\(fileSize) bytes)")
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
    
    private func parseJSONLFile(_ fileURL: URL, processedHashes: inout Set<String>, basePath: URL) async throws -> [UsageEntry] {
        // Get file size and track memory usage
        let fileSize = try fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        trackMemoryUsage(adding: fileSize)
        
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
                
                if let entry = parseUsageEntry(from: json, fileURL: fileURL, basePath: basePath) {
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
    
    private func parseUsageEntry(from json: [String: Any], fileURL: URL, basePath: URL) -> UsageEntry? {
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
        
        // Extract project path from JSON data (use cwd field if available)
        let projectPath = extractProjectPathFromJSON(json: json) ?? extractProjectPath(from: fileURL, basePath: basePath)
        
        return UsageEntry(
            timestamp: timestamp,
            inputTokens: inputTokens,
            outputTokens: outputTokens,
            cacheCreationTokens: cacheCreationTokens,
            cacheReadTokens: cacheReadTokens,
            model: model,
            cost: cost,
            messageId: messageId,
            requestId: requestId,
            projectPath: projectPath
        )
    }
    
    private func extractProjectPathFromJSON(json: [String: Any]) -> String? {
        // Extract the current working directory from the JSON data
        if let cwd = json["cwd"] as? String {
            return cwd
        }
        return nil
    }
    
    private func extractProjectPath(from fileURL: URL, basePath: URL) -> String? {
        // Extract the project path from the file URL
        // Claude stores files in structure: ~/.claude/projects/PROJECT_PATH/usage.jsonl
        // We want to extract the PROJECT_PATH part
        
        let filePath = fileURL.path
        let basePathStr = basePath.path
        
        // Remove the base path to get the relative path
        guard filePath.hasPrefix(basePathStr) else { return nil }
        
        let relativePath = String(filePath.dropFirst(basePathStr.count))
        let pathComponents = relativePath.components(separatedBy: "/").filter { !$0.isEmpty }
        
        // The first component should be the project path - return it as-is for cleaner display
        guard let projectComponent = pathComponents.first else { return nil }
        
        return projectComponent
    }
}

// MARK: - String Extension

extension String {
    var expandingTildeInPath: String {
        return NSString(string: self).expandingTildeInPath
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}