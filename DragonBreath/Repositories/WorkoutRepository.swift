import SwiftData
import Foundation

@Observable
final class WorkoutRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func save(_ workout: Workout) {
        context.insert(workout)
        try? context.save()
    }

    func delete(_ workout: Workout) {
        context.delete(workout)
        try? context.save()
    }

    func saveResult(_ result: WorkoutResult) {
        context.insert(result)
        try? context.save()
    }

    func deleteResult(_ result: WorkoutResult) {
        context.delete(result)
        try? context.save()
    }

    func saveWorkoutAndResult(_ workout: Workout, result: WorkoutResult) {
        context.insert(workout)
        context.insert(result)
        try? context.save()
    }

    // MARK: - Bulk import (insert without saving)

    func insert(_ workout: Workout) {
        context.insert(workout)
    }

    func insertResult(_ result: WorkoutResult) {
        context.insert(result)
    }

    func commit() {
        try? context.save()
    }

    func allWorkouts() -> [Workout] {
        (try? context.fetch(FetchDescriptor<Workout>())) ?? []
    }
}
