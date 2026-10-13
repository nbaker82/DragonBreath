import SwiftData
import Foundation

@Observable
final class LiftRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ log: LiftLog) {
        context.insert(log)
        try? context.save()
    }

    func delete(_ log: LiftLog) {
        context.delete(log)
        try? context.save()
    }

    // MARK: - Bulk import (insert without saving)

    func insertMovement(_ movement: Movement) {
        context.insert(movement)
    }

    func insertLog(_ log: LiftLog) {
        context.insert(log)
    }

    func commit() {
        try? context.save()
    }

    func allMovements() -> [Movement] {
        (try? context.fetch(FetchDescriptor<Movement>())) ?? []
    }
}
