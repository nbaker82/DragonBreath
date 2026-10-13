import SwiftUI
import SwiftData

// MARK: - Workout List ViewModel

@Observable
final class WorkoutListViewModel {
    var searchText: String = ""
    var selectedType: WorkoutType? = nil
    var selectedMovement: Movement? = nil
    var showBenchmarksOnly: Bool = false
    var startDate: Date? = nil
    var endDate: Date? = nil
    var sortOrder: WorkoutSortOrder = .nameAscending

    func filtered(_ workouts: [Workout]) -> [Workout] {
        WorkoutFilterLogic.apply(
            to: workouts,
            searchText: searchText,
            workoutType: selectedType,
            movementID: selectedMovement?.id,
            benchmarksOnly: showBenchmarksOnly,
            sortOrder: sortOrder
        )
    }
}

// MARK: - Workout Detail ViewModel

@Observable
final class WorkoutDetailViewModel {
    var workout: Workout
    var showingLogSheet: Bool = false

    init(workout: Workout) {
        self.workout = workout
    }

    var sortedResults: [WorkoutResult] {
        workout.results.sorted { $0.date > $1.date }
    }

    var personalBest: WorkoutResult? {
        guard let idx = PercentileLogic.personalBestIndex(
            in: workout.results,
            workoutType: workout.workoutType
        ) else { return nil }
        return workout.results[idx]
    }

    func percentile(for result: WorkoutResult) -> Double {
        PercentileLogic.percentile(
            for: result,
            in: workout.results,
            workoutType: workout.workoutType
        )
    }

    func percentileLabel(for result: WorkoutResult) -> String {
        PercentileLogic.label(for: percentile(for: result))
    }

    func percentileColor(for result: WorkoutResult) -> String {
        let p = percentile(for: result)
        if p >= 1.0 { return "gold" }
        if p >= 0.9 { return "green" }
        if p >= 0.75 { return "blue" }
        return "secondary"
    }
}
