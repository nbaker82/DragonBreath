import Foundation

// MARK: - Protocol

/// Describes the score fields PercentileLogic needs from a workout result.
protocol WorkoutResultScoring {
    var timeSeconds: Int? { get }
    var rounds: Int? { get }
    var repsRemainder: Int? { get }
    var weight: Double? { get }
    var totalReps: Int? { get }
}
