import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItemController: StatusItemController?
    private let monitor = ClipboardMonitor()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItemController = StatusItemController(monitor: monitor)
        monitor.start()
    }
}
