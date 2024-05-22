import Foundation
import AppKit

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

    let activeMemory = Double(stats.active_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
    let wiredMemory = Double(stats.wire_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB
    let compressedMemory = Double(stats.compressor_page_count) * Double(vm_page_size) / 1_073_741_824 // Convertimos a GB

    let usedMemory = activeMemory + wiredMemory + compressedMemory
    return min(usedMemory, getTotalMemory()) // Asegurarse de que no exceda la memoria total
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

func getTotalMemory() -> Double {
    return Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824 // Convertimos a GB
}
