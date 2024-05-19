import Cocoa
import SwiftUI

@main
struct ResourceMonitorApp: App {
    // Conectar el AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No se necesita WindowGroup aquí
        Settings {
            EmptyView() // Es necesario tener algo aquí, pero no necesita ser una ventana principal
        }
    }
}
