import SwiftUI
import AppKit
import Charts

// The ContentView struct is responsible for displaying the main user interface of the application.
struct ContentView: View {
    @State private var memoryUsage: String = "Fetching..."
    @State private var wiredMemoryUsage: String = "Fetching..."
    @State private var appMemoryUsage: String = "Fetching..."
    @State private var compressedMemoryUsage: String = "Fetching..."
    @State private var memoryData: [MemoryUsage] = []
    @State private var wiredMemoryData: [MemoryUsage] = []
    @State private var appMemoryData: [MemoryUsage] = []
    @State private var compressedMemoryData: [MemoryUsage] = []
    @State private var timer: Timer?
    @State private var isOnTop: Bool = false // Estado para el interruptor "on top"
    @State private var displayInGB: Bool = true // Mostrar en GB por defecto
    @State private var maxTime: Double = 30  // Agrega un estado para el tiempo máximo visible
    private let totalMemory: Double = getTotalMemory()

    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "memorychip")
                        .padding(.top, 12.0)
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    Text("RAM Usage")
                        .font(.largeTitle)
                        .padding(.top, 12.0)
                }
                .padding([.top, .leading], 15.0)
                .padding([.top, .trailing], 5.0) // Espacio entre "RAM Usage" y el divisor

                Spacer()

                Toggle(isOn: $isOnTop) {
                    EmptyView()
                }
                .toggleStyle(SmallPinToggleStyle())
                .padding([.top, .trailing], 31.0)
                .padding(.trailing, 7.0)
            }

            MemoryChartView(
                memoryData: memoryData,
                wiredMemoryData: wiredMemoryData,
                appMemoryData: appMemoryData,
                compressedMemoryData: compressedMemoryData,
                maxTime: maxTime
            )
            
            Divider()
                .padding(.vertical, 10)
            
            Text("Memory Details")
                .font(.headline)
                .padding(.bottom, 5)
            
            MemoryDetailsView(
                memoryUsage: $memoryUsage,
                wiredMemoryUsage: $wiredMemoryUsage,
                appMemoryUsage: $appMemoryUsage,
                compressedMemoryUsage: $compressedMemoryUsage,
                displayInGB: $displayInGB,
                totalMemory: totalMemory
            )
            
            Text("© 2024 Made with ♥ by c3nz.")
                .font(.footnote)
                .padding(.bottom, 17.0)
                .frame(height: 35.0)
        }
        .frame(minWidth: 650, minHeight: 530)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: isOnTop) {
            setWindowOnTop()
        }
    }

    // This method fetches the current memory usage and updates the memory data arrays.
    func fetchMemoryUsage() {
        let usedMemory = getSystemUsedMemory()
        let wiredMemory = getSystemWiredMemory()
        let appMemory = getAppMemory()
        let compressedMemory = getCompressedMemory()
        let usedMemoryPercentage = (usedMemory / totalMemory) * 100.0
        let wiredMemoryPercentage = (wiredMemory / totalMemory) * 100.0
        let appMemoryPercentage = (appMemory / totalMemory) * 100.0
        let compressedMemoryPercentage = (compressedMemory / totalMemory) * 100.0
        
        let currentTime = Date()
        let newData = MemoryUsage(time: currentTime, usage: min(usedMemoryPercentage, 100.0)) // Asegurarse de que no exceda 100%
        let newWiredData = MemoryUsage(time: currentTime, usage: min(wiredMemoryPercentage, 100.0)) // Asegurarse de que no exceda 100%
        let newAppData = MemoryUsage(time: currentTime, usage: min(appMemoryPercentage, 100.0)) // Asegurarse de que no exceda 100%
        let newCompressedData = MemoryUsage(time: currentTime, usage: min(compressedMemoryPercentage, 100.0)) // Asegurarse de que no exceda 100%
        memoryData.append(newData)
        wiredMemoryData.append(newWiredData)
        appMemoryData.append(newAppData)
        compressedMemoryData.append(newCompressedData)
        
        if memoryData.count > 30 {
            memoryData.removeFirst()
        }
        
        if wiredMemoryData.count > 30 {
            wiredMemoryData.removeFirst()
        }

        if appMemoryData.count > 30 {
            appMemoryData.removeFirst()
        }

        if compressedMemoryData.count > 30 {
            compressedMemoryData.removeFirst()
        }

        // Asegúrate de que el tiempo máximo sea el más reciente
        if let firstData = memoryData.first {
            maxTime = currentTime.timeIntervalSince(firstData.time)
        }

        updateMemoryUsageDisplay()
    }

    // This method updates the memory usage display based on the current memory usage values.
    func updateMemoryUsageDisplay() {
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
    
    // This method starts a timer to fetch memory usage data at regular intervals.
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            fetchMemoryUsage()
        }
    }

    // This method stops the timer that fetches memory usage data.
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // This method sets the application window to be always on top or not based on the isOnTop state.
    private func setWindowOnTop() {
        if let window = NSApplication.shared.windows.first {
            window.level = isOnTop ? .floating : .normal
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("MacOS")
    }
}
