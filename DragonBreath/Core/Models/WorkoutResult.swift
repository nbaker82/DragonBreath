import SwiftData
import Foundation

// MARK: - WorkoutResult

@Model
final class WorkoutResult {
    var id: UUID
    var workout: Workout?
    var date: Date
    var scoreType: ScoreType
    var timeSeconds: Int?       // For Time results
    var rounds: Int?            // AMRAP results
    var repsRemainder: Int?     // AMRAP remainder reps
    var weight: Double?         // Max load
    var totalReps: Int?         // Total rep count for chipper / rep-only scores
    var notes: String
    var rx: Bool                // Was it Rx or scaled?
    var isPersonalRecord: Bool
    var createdAt: Date

    init(
        workout: Workout,
        date: Date = Date(),
        scoreType: ScoreType,
        timeSeconds: Int? = nil,
        rounds: Int? = nil,
        repsRemainder: Int? = nil,
        weight: Double? = nil,
        totalReps: Int? = nil,
        notes: String = "",
        rx: Bool = true,
        isPersonalRecord: Bool = false
    ) {
        self.id = UUID()
        self.workout = workout
        self.date = date
        self.scoreType = scoreType
        self.timeSeconds = timeSeconds
        self.rounds = rounds
        self.repsRemainder = repsRemainder
        self.weight = weight
        self.totalReps = totalReps
        self.notes = notes
        self.rx = rx
        self.isPersonalRecord = isPersonalRecord
        self.createdAt = Date()
    }

    var displayScore: String {
        switch scoreType {
        case .time:
            guard let t = timeSeconds else { return "-" }
            let h = t / 3600
            let m = (t % 3600) / 60
            let s = t % 60
            if h > 0 {
                return String(format: "%d:%02d:%02d", h, m, s)
            }
            return String(format: "%d:%02d", m, s)
        case .rounds:
            let r = rounds ?? 0
            let reps = repsRemainder ?? 0
            return reps > 0 ? "\(r) rounds + \(reps) reps" : "\(r) rounds"
        case .weight:
            return weight.map { "\(Int($0)) lbs" } ?? "-"
        case .reps:
            // Free-form scores (Intervals, Custom, unparsed imports) are stored in notes.
            if let totalReps { return "\(totalReps) reps" }
            return notes.isEmpty ? "-" : notes
        default:
            return notes
        }
    }
}

// Stated explicitly so the conformance doesn't depend on @Model's macro expansion
// order; files elsewhere extend these models, which can otherwise hide it.
extension WorkoutResult: Identifiable {}
