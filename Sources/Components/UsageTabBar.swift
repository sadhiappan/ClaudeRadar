import SwiftUI

struct UsageTabBar: View {
    @Binding var selectedTab: UsageTab
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                TabButton(
                    title: "Model Usage",
                    isSelected: selectedTab == .models,
                    action: { selectedTab = .models }
                )
                .frame(width: geometry.size.width / 2)
                
                TabButton(
                    title: "Project Usage", 
                    isSelected: selectedTab == .projects,
                    action: { selectedTab = .projects }
                )
                .frame(width: geometry.size.width / 2)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, .spacingLg)
    }
}

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                // Underline
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}