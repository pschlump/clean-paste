import Foundation
import ServiceManagement

/// Wraps SMAppService so the app can register/unregister itself as a login item.
/// macOS 13+; the item appears in System Settings → General → Login Items.
enum LoginItemManager {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    /// Registers launch-at-login on first run; afterwards the user controls it
    /// from the app's menu or System Settings.
    static func registerIfNeeded() {
        let status = SMAppService.mainApp.status
        guard status == .notRegistered || status == .notFound else {
            NSLog("CleanPaste: login item already registered (status \(status.rawValue))")
            return
        }
        do {
            try SMAppService.mainApp.register()
            NSLog("CleanPaste: registered as login item (status \(SMAppService.mainApp.status.rawValue))")
        } catch {
            NSLog("CleanPaste: login item registration failed: \(error.localizedDescription)")
        }
    }

    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("CleanPaste: login item update failed: \(error.localizedDescription)")
        }
    }
}
