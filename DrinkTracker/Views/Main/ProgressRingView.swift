import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let totalCups: Int
    let goalCups: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 4) {
                Text("\(totalCups)")
                    .font(.system(size: 64, weight: .light))
                Text("of \(goalCups) cups")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
