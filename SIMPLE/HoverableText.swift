import SwiftUI

// The HoverableText struct is responsible for displaying text that shows a description when hovered over.
struct HoverableText: View {
    let text: String
    let description: String
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        // The Text view displays the provided text and shows a popover with the description when hovered over.
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
