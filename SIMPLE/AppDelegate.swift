import Cocoa
import SwiftUI

// The AppDelegate class is responsible for managing the application's lifecycle events.
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    // This method is called when the application has finished launching.
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 555),
            styleMask: [.titled, .closable, .miniaturizable, .resizable], // Exclude .resizable
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    // This method is called when the application is about to terminate.
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
