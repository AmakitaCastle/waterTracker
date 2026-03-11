import SwiftUI

struct StyledText: View {
    let text: String
    let style: Font

    var body: some View {
        Text(text)
            .font(style)
            .foregroundColor(.primary)
    }
}
