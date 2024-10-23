import SwiftUI

// The SmallPinToggleStyle struct is responsible for providing a custom toggle style with a pin icon.
struct SmallPinToggleStyle: ToggleStyle {
    // The makeBody method creates the view for the toggle.
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 40, height: 20)
                    .foregroundColor(configuration.isOn ? Color.green : Color.gray)
                Circle()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .overlay(
                        Image(systemName: "pin.fill")
                            .foregroundColor(configuration.isOn ? .green : .gray)
                            .offset(x: configuration.isOn ? 10 : -10)
                            .offset(y: 0.5)
                    )
                    .animation(.easeInOut(duration: 0.1), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}
