import SwiftUI
import Charts
import AppKit

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
    @State private var displayInGB: Bool = false // Estado para cambiar entre GB y porcentaje
    private let totalMemory: Double = getTotalMemory()
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "memorychip")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    Text("RAM Usage")
                        .font(.largeTitle)
                }
                .padding(.leading, 15.0)
                .padding(.trailing, 5.0) // Espacio entre "RAM Usage" y el divisor

                Divider()
                    .frame(width: 0.0, height: 40) // Ajusta la altura según sea necesario
                    .padding(.horizontal, 2.0) // Espacio alrededor del divisor

                Spacer()

                Toggle(isOn: $isOnTop) {
                    EmptyView()
                }
                .toggleStyle(SmallPinToggleStyle())
                .padding(.trailing, 38.0)
            }

            Chart {
                ForEach(memoryData) { data in
                    LineMark(
                        x: .value("Time", data.time.timeIntervalSinceNow),
                        y: .value("Memory Usage", data.usage),
                        series: .value("Type", "Used Memory")
                    )
                    .foregroundStyle(Color.green)
                }
                ForEach(wiredMemoryData) { data in
                    LineMark(
                        x: .value("Time", data.time.timeIntervalSinceNow),
                        y: .value("Wired Memory Usage", data.usage),
                        series: .value("Type", "Wired Memory")
                    )
                    .foregroundStyle(Color.orange)
                }
                ForEach(appMemoryData) { data in
                    LineMark(
                        x: .value("Time", data.time.timeIntervalSinceNow),
                        y: .value("Apps Memory Usage", data.usage),
                        series: .value("Type", "Apps Memory")
                    )
                    .foregroundStyle(Color.blue)
                }
                ForEach(compressedMemoryData) { data in
                    LineMark(
                        x: .value("Time", data.time.timeIntervalSinceNow),
                        y: .value("Compressed Memory Usage", data.usage),
                        series: .value("Type", "Compressed Memory")
                    )
                    .foregroundStyle(Color.purple)
                }
            }
            .chartYScale(domain: 0.0...100.0)
            .chartXScale(domain: -30...0)
            .chartXAxis {
                AxisMarks(values: Array(stride(from: -30, through: 0, by: 5))) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(abs(intValue))s")
                        }
                    }
                }
            }
            .frame(height: 200.0)
            .padding([.leading, .bottom, .trailing])
            
            Divider()
                .padding(.vertical, 10)
            
            Text("Memory Details")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 10) {
                VStack(spacing: 5) {
                    HStack {
                        Text("Used Memory")
                            .foregroundColor(.green)
                        Spacer()
                        Text("\(getSystemUsedMemory(), specifier: "%.2f") GB")
                            .foregroundColor(.green)
                    }
                    .background(Color.gray.opacity(0.2))
                    
                    HStack {
                        Text("Apps Memory")
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(getAppMemory(), specifier: "%.2f") GB")
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Wired Memory")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(getSystemWiredMemory(), specifier: "%.2f") GB")
                            .foregroundColor(.orange)
                    }
                    HStack {
                        Text("Compressed Memory")
                            .foregroundColor(.purple)
                        Spacer()
                        Text("\(getCompressedMemory(), specifier: "%.2f") GB")
                            .foregroundColor(.purple)
                    }
                }
                Divider()
                    .padding(.vertical, 10)
                VStack(spacing: 5) {
                    HStack {
                        Text("Cache")
                        Spacer()
                        Text("\(getCacheMemory(), specifier: "%.2f") GB")
                    }
                    HStack {
                        Text("Swap")
                        Spacer()
                        Text("\(getSwapMemory(), specifier: "%.2f") MB")
                    }
                }
            }
            .padding([.leading, .trailing])
            
            Text("© 2024 Made with ♥ by c3nz.")
                .font(.footnote)
                .padding(.top, 7.0)
        }
        .frame(minWidth: 623, minHeight: 520)
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

        updateMemoryUsageDisplay()
    }

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
            memoryUsage = String(format: "Used Memory: %.2f GB", usedMemory)
            wiredMemoryUsage = String(format: "Wired Memory: %.2f GB", wiredMemory)
            appMemoryUsage = String(format: "Apps Memory: %.2f GB", appMemory)
            compressedMemoryUsage = String(format: "Compressed Memory: %.2f GB", compressedMemory)
        } else {
            memoryUsage = String(format: "Used Memory: %.2f%%", usedMemoryPercentage)
            wiredMemoryUsage = String(format: "Wired Memory: %.2f%%", wiredMemoryPercentage)
            appMemoryUsage = String(format: "Apps Memory: %.2f%%", appMemoryPercentage)
            compressedMemoryUsage = String(format: "Compressed Memory: %.2f%%", compressedMemoryPercentage)
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            fetchMemoryUsage()
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func getSystemUsedMemory() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return -1
        }

        // Obtención de los valores de memoria
        let activeMemory = Double(stats.active_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        let wiredMemory = Double(stats.wire_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        let compressedMemory = Double(stats.compressor_page_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        let cacheMemory = (Double(stats.speculative_count) + Double(stats.external_page_count)) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB

        // Excluir memoria inactiva del cálculo
        let usedMemory = activeMemory + wiredMemory + compressedMemory + cacheMemory
        return min(usedMemory, totalMemory) // Asegurarse de que no exceda la memoria total
    }

    func getSystemWiredMemory() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return -1
        }

        let wiredMemory = Double(stats.wire_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        return wiredMemory
    }
    
    func getCacheMemory() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return -1
        }

        let cacheMemory = (Double(stats.speculative_count) + Double(stats.external_page_count)) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        return cacheMemory
    }
    
    func getSwapMemory() -> Double {
        var xswUsage = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size
        let result = sysctlbyname("vm.swapusage", &xswUsage, &size, nil, 0)
        guard result == 0 else {
            return -1
        }
        let swapUsed = Double(xswUsage.xsu_used) / 1_048_576 // Convertimos a MB
        return swapUsed
    }
    
    func getAppMemory() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return -1
        }

        let appMemory = Double(stats.internal_page_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        return appMemory
    }
    
    func getCompressedMemory() -> Double {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return -1
        }

        let compressedMemory = Double(stats.compressor_page_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
        return compressedMemory
    }

    static func getTotalMemory() -> Double {
        return Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824 // Convertimos a GB
    }

    private func setWindowOnTop() {
        if let window = NSApplication.shared.windows.first {
            window.level = isOnTop ? .floating : .normal
        }
    }
}

struct MemoryUsage: Identifiable {
    let id = UUID()
    let time: Date
    let usage: Double
}

struct SmallPinToggleStyle: ToggleStyle {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
