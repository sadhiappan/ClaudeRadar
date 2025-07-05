import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    init(progress: Double, color: Color = .blue, lineWidth: CGFloat = 4) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                // No animation - update live for data changes
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
        }
    }
}