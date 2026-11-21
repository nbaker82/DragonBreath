import Foundation

// MARK: - Pure Logic

enum WorkoutFilterLogic {

    /// Applies search, type, movement, benchmark, and sort filters to a list of workouts.
    static func apply<W: WorkoutFilterable>(
        to workouts: [W],
        searchText: String,
        workoutType: WorkoutType?,
        movementID: UUID?,
        benchmarksOnly: Bool,
        sortOrder: WorkoutSortOrder
    ) -> [W] {
        var result = workouts

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.workoutDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let type = workoutType {
            result = result.filter { $0.workoutType == type }
        }

        if let id = movementID {
            result = result.filter { $0.movementIDs.contains(id) }
        }

        if benchmarksOnly {
            result = result.filter { $0.isBenchmark }
        }

        switch sortOrder {
        case .nameAscending:  result.sort { $0.name < $1.name }
        case .nameDescending: result.sort { $0.name > $1.name }
        case .newest:         result.sort { $0.createdAt > $1.createdAt }
        case .oldest:         result.sort { $0.createdAt < $1.createdAt }
        }

        return result
    }
}
