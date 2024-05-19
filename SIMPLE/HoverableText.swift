import SwiftUI

struct HoverableText: View {
    let text: String
    let description: String
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Text(text)
            .onHover { hovering in
                isHovered = hovering
            }
            .popover(isPresented: $isHovered, arrowEdge: .bottom) {
                Text(description)
                    .padding()
                    .frame(width: 200)
            }
    }
}
