import Foundation

/// A parsed score, ready to store on a `WorkoutResult`.
struct WorkoutScore: Equatable {
    var scoreType: ScoreType
    var timeSeconds: Int? = nil
    var rounds: Int? = nil
    var repsRemainder: Int? = nil
    var weight: Double? = nil
    var totalReps: Int? = nil
}
