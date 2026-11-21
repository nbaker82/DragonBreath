import Foundation
import SwiftData

// MARK: - Workout: WorkoutFilterable

extension Workout: WorkoutFilterable {
    var movementIDs: [UUID] { movements.map(\.id) }
}
