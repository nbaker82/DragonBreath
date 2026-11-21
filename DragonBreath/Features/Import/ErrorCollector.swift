import SwiftUI

// MARK: - Error collection

/// Caps the number of per-row messages so a badly formatted file doesn't flood the UI.
struct ErrorCollector {
    private(set) var messages: [String] = []
    private var overflow = 0
    private let limit = 10

    mutating func add(_ message: String) {
        if messages.count < limit {
            messages.append(message)
        } else {
            overflow += 1
            let summary = "…and \(overflow) more skipped rows."
            if messages.count == limit { messages.append(summary) } else { messages[limit] = summary }
        }
    }
}
