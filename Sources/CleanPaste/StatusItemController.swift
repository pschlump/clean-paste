import Cocoa

final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let monitor: ClipboardMonitor

    init(monitor: ClipboardMonitor) {
        self.monitor = monitor
        super.init()
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "CleanPaste")
        }
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuWillOpen(_ menu: NSMenu) {
        rebuildMenu(menu)
    }

    private func rebuildMenu(_ menu: NSMenu) {
        menu.removeAllItems()

        let toggle = NSMenuItem(title: "Clean Up Clipboard", action: #selector(toggleCleanup), keyEquivalent: "")
        toggle.target = self
        toggle.state = monitor.cleanupEnabled ? .on : .off
        menu.addItem(toggle)

        let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        loginItem.target = self
        loginItem.state = LoginItemManager.isEnabled ? .on : .off
        menu.addItem(loginItem)

        menu.addItem(.separator())

        let header = NSMenuItem(title: "Recent Clips", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        if monitor.history.snapshots.isEmpty {
            let empty = NSMenuItem(title: "(nothing copied yet)", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        } else {
            for (index, snapshot) in monitor.history.snapshots.enumerated() {
                let item = NSMenuItem(title: Self.previewText(snapshot.preview),
                                      action: #selector(selectClip(_:)), keyEquivalent: "")
                item.target = self
                item.tag = index
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit CleanPaste", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    private static func previewText(_ raw: String) -> String {
        let collapsed = raw.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if collapsed.isEmpty { return "(non-text item)" }
        if collapsed.count > 40 { return String(collapsed.prefix(40)) + "…" }
        return collapsed
    }

    @objc private func toggleCleanup() {
        monitor.cleanupEnabled.toggle()
    }

    @objc private func toggleLaunchAtLogin() {
        LoginItemManager.setEnabled(!LoginItemManager.isEnabled)
    }

    @objc private func selectClip(_ sender: NSMenuItem) {
        guard let snapshot = monitor.history.snapshot(at: sender.tag) else { return }
        monitor.restore(snapshot)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
