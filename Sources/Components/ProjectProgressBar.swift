import SwiftUI

// MARK: - Project Progress Bar

struct ProjectProgressBar: View {
    let project: ProjectUsage
    let isLoading: Bool
    @State private var animatedProgress: Double = 0.0
    @EnvironmentObject var themeManager: ThemeManager
    
    init(project: ProjectUsage, isLoading: Bool = false) {
        self.project = project
        self.isLoading = isLoading
    }
    
    var body: some View {
        Group {
            if isLoading {
                ShimmerProgressBar()
            } else {
                normalProgressView
            }
        }
    }
    
    private var normalProgressView: some View {
        VStack(alignment: .leading, spacing: .spacingSm) {
            // Project header with usage info
            HStack {
                // Project indicator dot and name
                HStack(spacing: .spacingSm) {
                    Circle()
                        .fill(project.color)
                        .frame(width: .spacingSm, height: .spacingSm)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(project.displayName)
                            .font(.body)
                            .fontWeight(.medium)
                            .highContrastAdjusted(color: .primary)
                        
                        Text("\(project.formattedTokenCount) tokens • \(project.sessionCount) sessions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Percentage (matching model usage style)
                Text("\(Int(project.percentage))%")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // Progress
                    Rectangle()
                        .fill(project.color)
                        .opacity(0.8)
                        .frame(
                            width: geometry.size.width * (project.percentage / 100.0),
                            height: 6
                        )
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
            
            // Bottom metrics (matching model usage layout)
            HStack {
                Text("Avg: \(project.averageTokensDisplay)/session")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if project.lastUsedDisplay == "Active now" {
                    Text("Active now")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Last: \(project.lastUsedDisplay)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            animatedProgress = project.percentage / 100.0
        }
        .onChange(of: project.percentage) { oldValue, newValue in
            animatedProgress = newValue / 100.0
        }
    }
}

// MARK: - Project Progress Collection

struct ProjectProgressCollection: View {
    let projects: [ProjectUsage]
    let style: ProgressBarStyle
    
    enum ProgressBarStyle {
        case standard
        case compact
    }
    
    var body: some View {
        LazyVStack(spacing: .spacingSm) {
            ForEach(projects.prefix(3)) { project in
                ProjectProgressBar(project: project)
            }
        }
    }
}