# Project Architecture

## Overview

The SIMPLE project is a macOS application designed to monitor and display memory usage in real-time. The application provides a graphical representation of memory usage, including used memory, wired memory, app memory, and compressed memory. It also offers detailed memory usage statistics and allows users to toggle the display between gigabytes (GB) and percentage (%).

## Main Components

### 1. AppDelegate
The `AppDelegate` class is responsible for managing the application's lifecycle events. It creates the main window and sets the content view.

### 2. ContentView
The `ContentView` struct is responsible for displaying the main user interface of the application. It includes the memory usage chart, memory details, and a toggle switch to keep the application window on top.

### 3. MemoryChartView
The `MemoryChartView` struct is responsible for displaying a chart of memory usage over time. It uses the SwiftUI Charts framework to create a line chart that shows the memory usage data.

### 4. MemoryDetailsView
The `MemoryDetailsView` struct is responsible for displaying detailed memory usage information. It includes progress bars for used memory, wired memory, app memory, and compressed memory, as well as additional details for cached and swap memory.

### 5. MemoryFunctions
The `MemoryFunctions` file contains functions for retrieving memory usage data from the system. These functions include `getSystemUsedMemory`, `getSystemWiredMemory`, `getCacheMemory`, `getSwapMemory`, `getAppMemory`, `getCompressedMemory`, and `getTotalMemory`.

### 6. MemoryUsage
The `MemoryUsage` struct represents memory usage data at a specific point in time. It includes properties for the time and usage percentage.

### 7. ProgressBarBackground
The `ProgressBarBackground` struct is responsible for displaying a background for a progress bar. It uses a `GeometryReader` to provide the size of the container view and a `Rectangle` to display the progress.

### 8. SIMPLEApp
The `SIMPLEApp` struct is the main entry point for the application. It connects the `AppDelegate` and provides the settings scene.

### 9. SmallPinToggleStyle
The `SmallPinToggleStyle` struct is responsible for providing a custom toggle style with a pin icon. It creates a view for the toggle using a `HStack` and a `ZStack`.

### 10. HoverableText
The `HoverableText` struct is responsible for displaying text that shows a description when hovered over. It uses the `onHover` modifier to detect when the text is hovered and displays a popover with the description.

## Component Interactions

- The `AppDelegate` creates the main window and sets the `ContentView` as the content view.
- The `ContentView` fetches memory usage data using the functions in `MemoryFunctions` and updates the `MemoryChartView` and `MemoryDetailsView` with the data.
- The `MemoryChartView` displays the memory usage data as a line chart.
- The `MemoryDetailsView` displays detailed memory usage information using progress bars and additional details.
- The `HoverableText` struct is used in the `MemoryDetailsView` to display descriptions for each memory type.
- The `ProgressBarBackground` struct is used in the `MemoryDetailsView` to display the background for the progress bars.
- The `SmallPinToggleStyle` struct is used in the `ContentView` to provide a custom toggle style for the "on top" switch.

## Conclusion

The SIMPLE project is designed with a modular architecture, where each component has a specific responsibility. This modularity makes the codebase easier to understand, maintain, and extend. The use of SwiftUI and the Charts framework allows for a modern and responsive user interface, providing real-time memory usage monitoring and detailed statistics.
