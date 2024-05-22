import SwiftUI

struct ProgressBarBackground: View {
    var usage: Double
    var color: Color
    private let cornerRadius: CGFloat = 5.0
    private let height: CGFloat = 10.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: CGFloat(usage) * geometry.size.width, height: height)
                    .opacity(0.5)
                    .cornerRadius(cornerRadius)
            }
        }
        .frame(height: height)
    }
}
