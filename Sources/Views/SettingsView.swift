import SwiftUI

extension TimeZone {
    var offsetString: String {
        let hours = secondsFromGMT() / 3600
        let minutes = abs(secondsFromGMT() % 3600) / 60
        
        if minutes == 0 {
            return String(format: "%+d", hours)
        } else {
            return String(format: "%+d:%02d", hours, minutes)
        }
    }
}

struct SettingsView: View {
    @AppStorage("tokenPlan") private var tokenPlan: TokenPlan = .pro
    @AppStorage("refreshInterval") private var refreshInterval: Double = 3.0
    @AppStorage("showNotifications") private var showNotifications: Bool = true
    @AppStorage("notificationThreshold") private var notificationThreshold: Double = 0.8
    @AppStorage("claudeDataPath") private var claudeDataPath: String = ""
    @AppStorage("preferredTimezone") private var preferredTimezone: String = TimeZone.current.identifier
    
    var body: some View {
        TabView {
            GeneralSettingsView(
                tokenPlan: $tokenPlan,
                refreshInterval: $refreshInterval,
                claudeDataPath: $claudeDataPath,
                preferredTimezone: $preferredTimezone
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            NotificationSettingsView(
                showNotifications: $showNotifications,
                notificationThreshold: $notificationThreshold
            )
            .tabItem {
                Label("Notifications", systemImage: "bell")
            }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(minWidth: 500, idealWidth: 600, maxWidth: 800,
               minHeight: 550, idealHeight: 650, maxHeight: 800)
    }
}

struct GeneralSettingsView: View {
    @Binding var tokenPlan: TokenPlan
    @Binding var refreshInterval: Double
    @Binding var claudeDataPath: String
    @Binding var preferredTimezone: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Token Plan Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Token Plan")
                        .font(.headline)
                    
                    Picker("Plan", selection: $tokenPlan) {
                        ForEach(TokenPlan.allCases, id: \.self) { plan in
                            Text(plan.displayName).tag(plan)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text(tokenPlan.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Theme Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Appearance")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Theme:")
                            Spacer()
                        }
                        
                        Picker("Theme", selection: $themeManager.userPreference) {
                            ForEach(ThemePreference.allCases, id: \.self) { preference in
                                Text(preference.displayName).tag(preference)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text("Choose how ClaudeRadar appears. Auto follows your system theme.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Data Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Data Settings")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Claude Data Path", text: $claudeDataPath)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Browse") {
                                selectClaudeDataPath()
                            }
                        }
                        
                        Text("Leave empty to auto-detect Claude data directory")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Refresh Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Refresh Settings")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Update Interval:")
                            Spacer()
                            Text("\(String(format: "%.1f", refreshInterval))s")
                                .frame(width: 40)
                        }
                        
                        Slider(value: $refreshInterval, in: 1...10, step: 0.5) {
                            Text("Interval")
                        }
                        
                        Text("How often to refresh token usage data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Time Zone Settings Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Zone Settings")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Preferred Time Zone:")
                            Spacer()
                        }
                        
                        Menu {
                            ForEach(popularTimezones, id: \.identifier) { timezone in
                                Button(timezoneDisplayName(for: timezone)) {
                                    preferredTimezone = timezone.identifier
                                }
                            }
                            
                            Divider()
                            
                            Button("System Default") {
                                preferredTimezone = TimeZone.current.identifier
                            }
                        } label: {
                            HStack {
                                Text(selectedTimezoneDisplayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Text("Times will be displayed in your selected time zone")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    // MARK: - Timezone Helpers
    
    private var selectedTimezoneDisplayName: String {
        if let timezone = TimeZone(identifier: preferredTimezone) {
            return timezoneDisplayName(for: timezone)
        }
        return "System Default"
    }
    
    private func timezoneDisplayName(for timezone: TimeZone) -> String {
        return "\(timezone.localizedName(for: .standard, locale: .current) ?? timezone.identifier) (GMT\(timezone.offsetString))"
    }
    
    private var popularTimezones: [TimeZone] {
        let identifiers = [
            "America/New_York",    // Eastern Time
            "America/Chicago",     // Central Time  
            "America/Denver",      // Mountain Time
            "America/Los_Angeles", // Pacific Time
            "Europe/London",       // GMT/BST
            "Europe/Paris",        // CET
            "Europe/Berlin",       // CET
            "Asia/Tokyo",          // JST
            "Asia/Shanghai",       // CST
            "Asia/Kolkata",        // IST
            "Australia/Sydney",    // AEST
            "UTC"                  // UTC
        ]
        
        return identifiers.compactMap { TimeZone(identifier: $0) }
    }
    
    private func selectClaudeDataPath() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                claudeDataPath = url.path
            }
        }
    }
}

struct NotificationSettingsView: View {
    @Binding var showNotifications: Bool
    @Binding var notificationThreshold: Double
    
    var body: some View {
        Form {
            Section("Notification Settings") {
                Toggle("Enable Notifications", isOn: $showNotifications)
                
                if showNotifications {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Warning Threshold:")
                            Spacer()
                            Text("\(Int(notificationThreshold * 100))%")
                                .frame(width: 40)
                        }
                        
                        Slider(value: $notificationThreshold, in: 0.5...0.95, step: 0.05) {
                            Text("Threshold")
                        }
                        
                        Text("Get notified when token usage exceeds this percentage")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Notification Types") {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Token limit warnings", isOn: .constant(true))
                        .disabled(true)
                    Toggle("Session expiry alerts", isOn: .constant(true))
                        .disabled(true)
                    Toggle("Burn rate notifications", isOn: .constant(true))
                        .disabled(true)
                    
                    Text("Additional notification types will be available in future updates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .disabled(!showNotifications)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gauge.high")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("ClaudeRadar")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("A beautiful, native macOS app for monitoring Claude AI token usage")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Link("View on GitHub", destination: URL(string: "https://github.com/yourusername/ClaudeRadar")!)
                    .buttonStyle(.borderedProminent)
                
                HStack(spacing: 20) {
                    Link("Report Bug", destination: URL(string: "https://github.com/yourusername/ClaudeRadar/issues")!)
                        .buttonStyle(.bordered)
                    
                    Link("Feature Request", destination: URL(string: "https://github.com/yourusername/ClaudeRadar/issues")!)
                        .buttonStyle(.bordered)
                }
            }
            
            Spacer()
            
            Text("Made with ❤️ for the Claude community")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}