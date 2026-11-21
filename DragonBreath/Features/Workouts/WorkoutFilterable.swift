import Foundation
import SwiftData

// MARK: - Protocol

/// Describes the properties WorkoutFilterLogic needs from a workout.
/// Conforming to this protocol (rather than using Workout directly)
/// lets us test the logic with plain structs instead of SwiftData models.
protocol WorkoutFilterable {
    var name: String { get }
    var workoutDescription: String { get }
    var workoutType: WorkoutType { get }
    var isBenchmark: Bool { get }
    var createdAt: Date { get }
    /// IDs of the movements associated with this workout.
    var movementIDs: [UUID] { get }
}
