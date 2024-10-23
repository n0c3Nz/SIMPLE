import SwiftUI

// The MemoryDetailsView struct is responsible for displaying detailed memory usage information.
struct MemoryDetailsView: View {
    @Binding var memoryUsage: String
    @Binding var wiredMemoryUsage: String
    @Binding var appMemoryUsage: String
    @Binding var compressedMemoryUsage: String
    @Binding var displayInGB: Bool
    let totalMemory: Double

    @State private var windowSize: CGSize = .zero
    @State private var isResizing = false
    @State private var resizeTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                VStack(spacing: 5) {
                    HStack {
                        HoverableText(text: "Used", description: "This is the total memory used by the system.")
                            .padding(.trailing, 42.0)
                            .frame(width: 74.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            .frame(height: 19)

                        ProgressBarBackground(usage: getSystemUsedMemory() / totalMemory, color: .green)
                            .frame(width: 420, height: 20) // Ajustar el tamaño según sea necesario

                        Text(memoryUsage)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 24.0)
                            .frame(width: 100.0)
                    }
                    .padding(.leading, 23.0)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .onAppear {
                        updateMemoryUsageDisplay()
                    }

                    HStack {
                        HoverableText(text: "Apps", description: "This is the memory used by all running applications.")
                            .padding(.trailing, 20.0)
                            .frame(width: 98.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            .frame(height: 20)

                        ProgressBarBackground(usage: getAppMemory() / totalMemory, color: Color(red: 0.7, green: 1, blue: 0.1))
                            .frame(width: 420.0, height: 20) // Ajustar el tamaño según sea necesario

                        Text(appMemoryUsage)
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 0.7, green: 1, blue: 0.1)) // Valores entre 0 y 1
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 17.0)
                            .frame(width: 100.0)
                    }

                    HStack {
                        HoverableText(text: "Wired", description: "This is the memory that cannot be paged out to disk.")
                            .padding(.trailing, 18.0)
                            .frame(width: 98.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            .frame(height: 20)
                        ProgressBarBackground(usage: getSystemWiredMemory() / totalMemory, color: .orange)
                            .frame(width: 420.0, height: 20) // Ajustar el tamaño según sea necesario

                        Text(wiredMemoryUsage)
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 14.0)
                            .frame(width: 100.0)
                    }

                    HStack {
                        HoverableText(text: "Compressed", description: "This is the memory that is compressed to save space.")
                            .padding(.leading, 19.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            .frame(width: 100.0, height: 20)
                        ProgressBarBackground(usage: getCompressedMemory() / totalMemory, color: Color(hue: 0.541, saturation: 0.489, brightness: 0.699))
                            .frame(width: 420.0, height: 20) // Ajustar el tamaño según sea necesario

                        Text(compressedMemoryUsage)
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundColor(Color(hue: 0.541, saturation: 0.489, brightness: 0.699)) // Valores entre 0 y 1
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 19.0)
                            .frame(width: 100.0)
                    }
                }
                Divider()
                    .padding(.vertical, 5)
                VStack(alignment: .center, spacing: 5) {
                    HStack(alignment: .center, spacing: 5) {
                        Spacer()
                        HoverableText(text: "Cached", description: "This is the memory used for caching data.")
                            .frame(width: 50.0)
                            .padding(.trailing, 250.0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("\(getCacheMemory(), specifier: "%.2f") GB")
                            .font(.callout)
                            //.multilineTextAlignment(.trailing)
                            .frame(width: 50.0)
                            .padding(.leading, 223.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    HStack(alignment: .center) {
                        HoverableText(text: "Swap", description: "This is the amount of data swapped to disk.")
                            .frame(width: 50.0)
                            .padding(.trailing, 247.0)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("\(getSwapMemory(), specifier: "%.2f") MB")
                            .font(.callout)
                            //.multilineTextAlignment(.trailing)
                            .frame(width: 50)
                            .padding(.leading, 228.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding([.leading, .trailing])
            .onChange(of: geometry.size) { oldSize, newSize in
                if oldSize != newSize {
                    isResizing = true
                    resizeTimer?.invalidate()
                    resizeTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        isResizing = false
                        updateMemoryUsageDisplay()
                    }
                }
            }
        }
    }
    
    // This method updates the memory usage display based on the current memory usage values.
    func updateMemoryUsageDisplay() {
        guard !isResizing else { return }
        
        let usedMemory = getSystemUsedMemory()
        let wiredMemory = getSystemWiredMemory()
        let appMemory = getAppMemory()
        let compressedMemory = getCompressedMemory()
        let usedMemoryPercentage = (usedMemory / totalMemory) * 100.0
        let wiredMemoryPercentage = (wiredMemory / totalMemory) * 100.0
        let appMemoryPercentage = (appMemory / totalMemory) * 100.0
        let compressedMemoryPercentage = (compressedMemory / totalMemory) * 100.0

        if displayInGB {
            memoryUsage = String(format: "%.2f GB", usedMemory)
            wiredMemoryUsage = String(format: "%.2f GB", wiredMemory)
            appMemoryUsage = String(format: "%.2f GB", appMemory)
            compressedMemoryUsage = String(format: "%.2f GB", compressedMemory)
        } else {
            memoryUsage = String(format: "%.2f%%", usedMemoryPercentage)
            wiredMemoryUsage = String(format: "%.2f%%", wiredMemoryPercentage)
            appMemoryUsage = String(format: "%.2f%%", appMemoryPercentage)
            compressedMemoryUsage = String(format: "%.2f%%", compressedMemoryPercentage)
        }
    }
}
