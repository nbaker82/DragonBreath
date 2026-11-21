import Foundation

/// Focusable fields in the workout logging forms, used to dismiss the keyboard.
enum ScoreField: Hashable {
    case minutes, seconds, rounds, reps, weight, totalReps, notes, workoutName
}
