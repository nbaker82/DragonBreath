import Foundation

/// The text typed into the score fields, and the rules for turning it into a score.
/// Shared by Log Result (existing workout) and Log What I Did (new workout).
struct ScoreEntry: Equatable {
    var minutes = ""
    var seconds = ""
    var rounds = ""
    var reps = ""
    var weight = ""
    var totalReps = ""

    /// Workout types scored by finishing time (MIN:SEC fields).
    static func isTimed(_ type: WorkoutType) -> Bool {
        [.forTime, .rft, .chipper].contains(type)
    }

    /// Seconds must be 0–59; only time scores have a seconds field.
    func secondsAreInvalid(for type: WorkoutType) -> Bool {
        Self.isTimed(type) && (Int(seconds) ?? 0) > 59
    }

    func score(for type: WorkoutType) -> WorkoutScore {
        switch type {
        case .forTime, .rft, .chipper:
            WorkoutScore(scoreType: .time, timeSeconds: (Int(minutes) ?? 0) * 60 + (Int(seconds) ?? 0))
        case .amrap, .emom, .deathBy:
            WorkoutScore(scoreType: .rounds, rounds: Int(rounds), repsRemainder: Int(reps))
        case .tabata:
            WorkoutScore(scoreType: .reps, totalReps: Int(totalReps))
        case .maxLoad, .strength, .complex:
            // Locale-aware, so "102,5" works where the decimal pad shows a comma.
            WorkoutScore(scoreType: .weight, weight: try? Double(weight, format: .number))
        default:
            // Free-form types (Intervals, Custom) keep their score in notes.
            WorkoutScore(scoreType: .reps)
        }
    }
}
