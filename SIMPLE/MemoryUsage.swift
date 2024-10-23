import Foundation

// The MemoryUsage struct represents memory usage data at a specific point in time.
struct MemoryUsage: Identifiable {
    // Unique identifier for each memory usage data point.
    let id = UUID()
    // The time at which the memory usage data was recorded.
    let time: Date
    // The percentage of memory usage at the recorded time.
    let usage: Double
}
