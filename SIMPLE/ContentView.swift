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

            Chart {
                ForEach(memoryData) { data in
                    LineMark(
                        x: .value("Time", Date().timeIntervalSince(data.time)),
                        y: .value("Memory Usage", data.usage),
                        series: .value("Type", "Used Memory")
                    )
                    .foregroundStyle(Color.green)
                }
                ForEach(wiredMemoryData) { data in
                    LineMark(
                        x: .value("Time", Date().timeIntervalSince(data.time)),
                        y: .value("Wired Memory Usage", data.usage),
                        series: .value("Type", "Wired Memory")
                    )
                    .foregroundStyle(Color.orange)
                    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 3])) // Línea discontinua
                }
                ForEach(appMemoryData) { data in
                    LineMark(
                        x: .value("Time", Date().timeIntervalSince(data.time)),
                        y: .value("Apps Memory Usage", data.usage),
                        series: .value("Type", "Apps Memory")
                    )
                    .foregroundStyle(Color(red: 0.7, green: 1, blue: 0.1)) // Valores entre 0 y 1
                }
                ForEach(compressedMemoryData) { data in
                    LineMark(
                        x: .value("Time", Date().timeIntervalSince(data.time)),
                        y: .value("Compressed Memory Usage", data.usage),
                        series: .value("Type", "Compressed Memory")
                    )
                    .foregroundStyle(Color(hue: 0.541, saturation: 0.489, brightness: 0.699)) // Valores entre 0 y 1
                }
            }
            .chartYScale(domain: 0.0...100.0)
            .chartXScale(domain: 0...maxTime)  // Usa el valor dinámico para la escala
            .chartXAxis {
                AxisMarks(values: Array(stride(from: 0, through: maxTime, by: 5))) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue)s")
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
                        HoverableText(text: "Used", description: "This is the total memory used by the system.")
                            .padding(.trailing, 45.0)
                            .frame(width: 79.0, height: 0.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            
                        ProgressBarBackground(usage: getSystemUsedMemory() / totalMemory, color: .green)
                            .frame(width: 420, height: 20) // Ajustar el tamaño según sea necesario
                        Spacer()
                        Text(memoryUsage)
                            .foregroundColor(.green)
                    }

                    HStack {
                        HoverableText(text: "Apps", description: "This is the memory used by all running applications.")
                            .padding(.trailing, 47.0)
                            .frame(width: 80.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }

                            .frame(height: 20)
                        ProgressBarBackground(usage: getAppMemory() / totalMemory, color: Color(red: 0.7, green: 1, blue: 0.1))
                            .frame(width: 420.0, height: 20) // Ajustar el tamaño según sea necesario
                        Spacer()
                        Text(appMemoryUsage)
                            .foregroundColor(Color(red: 0.7, green: 1, blue: 0.1)) // Valores entre 0 y 1
                    }

                    HStack {
                        HoverableText(text: "Wired", description: "This is the memory that cannot be paged out to disk.")
                            .padding(.trailing, 44.0)
                            .frame(width: 80.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            .frame(height: 20)
                        ProgressBarBackground(usage: getSystemWiredMemory() / totalMemory, color: .orange)
                            .frame(width: 420.0, height: 20) // Ajustar el tamaño según sea necesario
                        Spacer()
                        Text(wiredMemoryUsage)
                            .foregroundColor(.orange)
                    }

                    HStack {
                        HoverableText(text: "Compressed", description: "This is the memory that is compressed to save space.")
                            .padding(.trailing, 2.0)
                            .onTapGesture {
                                displayInGB.toggle()
                                updateMemoryUsageDisplay()
                            }
                            .frame(width: 80.0, height: 20)
                        ProgressBarBackground(usage: getCompressedMemory() / totalMemory, color: Color(hue: 0.541, saturation: 0.489, brightness: 0.699))
                            .frame(width: 420.0, height: 20) // Ajustar el tamaño según sea necesario
                        Spacer()
                        Text(compressedMemoryUsage)
                            .foregroundColor(Color(hue: 0.541, saturation: 0.489, brightness: 0.699)) // Valores entre 0 y 1
                    }
                }
                Divider()
                    .padding(.vertical, 5)
                VStack(spacing: 5) {
                    HStack {
                        HoverableText(text: "Cached", description: "This is the memory used for caching data.")
                            .padding(.trailing, 36.0)
                        Spacer()
                        Text("\(getCacheMemory(), specifier: "%.2f") GB")
                    }
                    HStack {
                        HoverableText(text: "Swap", description: "This is the amount of data swapped to disk.")
                            .padding(.trailing, 49.0)
                        Spacer()
                        Text("\(getSwapMemory(), specifier: "%.2f") MB")
                    }
                }
            }
            .padding([.leading, .trailing])
            
            Text("© 2024 Made with ♥ by c3nz.")
                .font(.footnote)
                .padding(.bottom, 17.0)
                .frame(height: 35.0)
        }
        .frame(minWidth: 623, minHeight: 530)
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

        // Asegúrate de que el tiempo máximo sea el más reciente
        if let firstData = memoryData.first {
            maxTime = currentTime.timeIntervalSince(firstData.time)
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

        // Excluir memoria inactiva del cálculo
        let usedMemory = activeMemory + wiredMemory + compressedMemory
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

struct ProgressBarBackground: View {
    var usage: Double
    var color: Color
    private let cornerRadius: CGFloat = 5.0 // Define el valor del radio de las esquinas aquí
    private let height: CGFloat = 10.0 // Define la altura aquí

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: CGFloat(usage) * geometry.size.width, height: height) // Aplicar la altura
                    .opacity(0.5)
                    .cornerRadius(cornerRadius) // Aplicar el radio de las esquinas
            }
        }
        .frame(height: height) // Establecer la altura del contenedor GeometryReader
    }
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
