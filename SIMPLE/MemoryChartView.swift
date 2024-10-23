import SwiftUI
import Charts

// The MemoryChartView struct is responsible for displaying a chart of memory usage over time.
struct MemoryChartView: View {
    var memoryData: [MemoryUsage]
    var wiredMemoryData: [MemoryUsage]
    var appMemoryData: [MemoryUsage]
    var compressedMemoryData: [MemoryUsage]
    var maxTime: Double

    var body: some View {
        // The Chart view displays the memory usage data as a line chart.
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
    }
}
