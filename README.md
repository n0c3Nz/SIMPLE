# SIMPLE

## Project Description

SIMPLE is a macOS application designed to monitor and display memory usage in real-time. It provides a graphical representation of memory usage, including used memory, wired memory, app memory, and compressed memory. The application also offers detailed memory usage statistics and allows users to toggle the display between gigabytes (GB) and percentage (%).

## Features

- Real-time memory usage monitoring
- Graphical representation of memory usage
- Detailed memory usage statistics
- Toggle display between GB and %
- Option to keep the application window on top

## Setup Instructions

To build and run the project, follow these steps:

1. Clone the repository:
   ```sh
   git clone https://github.com/n0c3Nz/SIMPLE.git
   cd SIMPLE
   ```

2. Open the project in Xcode:
   ```sh
   open SIMPLE.xcodeproj
   ```

3. Build and run the project:
   - Select the target device (e.g., My Mac) in the Xcode toolbar.
   - Click the "Run" button or press `Cmd + R` to build and run the project.

## Usage Instructions

1. Launch the application.
2. The main window will display real-time memory usage statistics.
3. Hover over the "Memory Details" section to see brief descriptions of each memory type.
4. Click on the memory details to toggle the display between GB and %.
5. Use the toggle switch in the top-right corner to keep the application window on top.
6. The memory usage graph will update every second, showing the most recent 30 seconds of data.

## Nota

Si pasas el mouse por encima de los Memory Details te da una breve descripción en cada uno de ellos y si haces click, mostrará el porcentaje de uso en lugar de los GB.
