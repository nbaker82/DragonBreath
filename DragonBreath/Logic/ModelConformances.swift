import Foundation

// MARK: - Workout: WorkoutFilterable

extension Workout: WorkoutFilterable {
    var movementIDs: [UUID] { movements.map(\.id) }
}

// MARK: - WorkoutResult: WorkoutResultScoring

extension WorkoutResult: WorkoutResultScoring {}

// MARK: - LiftLog: LiftLoggable

extension LiftLog: LiftLoggable {
    var movementID: UUID? { movement?.id }
    var movementName: String? { movement?.name }
}
