import Cocoa
import ServiceManagement

// Maintenance mode: remove the login item without launching the UI.
// Usage: CleanPaste.app/Contents/MacOS/CleanPaste --remove-login-item
if CommandLine.arguments.contains("--remove-login-item") {
    do {
        try SMAppService.mainApp.unregister()
        print("CleanPaste: login item removed (status \(SMAppService.mainApp.status.rawValue))")
    } catch {
        print("CleanPaste: failed to remove login item: \(error.localizedDescription)")
    }
    exit(0)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
