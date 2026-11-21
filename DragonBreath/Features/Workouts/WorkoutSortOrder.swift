import Foundation

// MARK: - Sort Order

enum WorkoutSortOrder: String, CaseIterable {
    case nameAscending  = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case newest         = "Newest First"
    case oldest         = "Oldest First"
}
