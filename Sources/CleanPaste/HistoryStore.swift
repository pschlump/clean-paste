import Cocoa

/// A captured copy/cut operation: every pasteboard item, as type-identifier -> data,
/// so the clipboard can be restored exactly as it was.
struct ClipboardSnapshot {
    let items: [[String: Data]]
    let preview: String
}

final class HistoryStore {
    private(set) var snapshots: [ClipboardSnapshot] = []
    let capacity = 5

    var onChange: (() -> Void)?

    func add(_ snapshot: ClipboardSnapshot) {
        if snapshots.first?.preview == snapshot.preview { return }
        snapshots.insert(snapshot, at: 0)
        if snapshots.count > capacity { snapshots.removeLast() }
        onChange?()
    }

    func snapshot(at index: Int) -> ClipboardSnapshot? {
        guard snapshots.indices.contains(index) else { return nil }
        return snapshots[index]
    }
}
