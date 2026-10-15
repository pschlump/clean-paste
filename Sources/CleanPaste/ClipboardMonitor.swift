import Cocoa

/// Polls the general pasteboard; records each copy/cut into the history and,
/// when cleanup is enabled, rewrites rich content as plain text.
final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?

    let history = HistoryStore()

    var cleanupEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "cleanupEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "cleanupEnabled") }
    }

    init() {
        lastChangeCount = pasteboard.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    private func poll() {
        let count = pasteboard.changeCount
        guard count != lastChangeCount else { return }
        lastChangeCount = count

        guard let snapshot = Self.makeSnapshot(from: pasteboard) else { return }
        history.add(snapshot)

        // Flatten to plain text. Guarded by string presence so pure file/image
        // copies with no text representation are left untouched.
        if cleanupEnabled, let text = pasteboard.string(forType: .string) {
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
            lastChangeCount = pasteboard.changeCount
        }
    }

    /// Writes a snapshot back to the clipboard without triggering cleanup or history.
    func restore(_ snapshot: ClipboardSnapshot) {
        pasteboard.clearContents()
        let items = snapshot.items.map { dict -> NSPasteboardItem in
            let item = NSPasteboardItem()
            for (type, data) in dict {
                item.setData(data, forType: NSPasteboard.PasteboardType(type))
            }
            return item
        }
        pasteboard.writeObjects(items)
        lastChangeCount = pasteboard.changeCount
    }

    private static func makeSnapshot(from pasteboard: NSPasteboard) -> ClipboardSnapshot? {
        guard let items = pasteboard.pasteboardItems, !items.isEmpty else { return nil }
        var dicts: [[String: Data]] = []
        for item in items {
            var dict: [String: Data] = [:]
            for type in item.types {
                if let data = item.data(forType: type) {
                    dict[type.rawValue] = data
                }
            }
            dicts.append(dict)
        }
        return ClipboardSnapshot(items: dicts, preview: previewString(from: pasteboard))
    }

    private static func previewString(from pasteboard: NSPasteboard) -> String {
        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            return text
        }
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty {
            return urls.map(\.lastPathComponent).joined(separator: ", ")
        }
        return "(non-text item)"
    }
}
