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
