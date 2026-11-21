import Foundation
import SwiftData

extension WorkoutResult {
    convenience init(workout: Workout, date: Date, score: WorkoutScore, notes: String, rx: Bool) {
        self.init(
            workout: workout,
            date: date,
            scoreType: score.scoreType,
            timeSeconds: score.timeSeconds,
            rounds: score.rounds,
            repsRemainder: score.repsRemainder,
            weight: score.weight,
            totalReps: score.totalReps,
            notes: notes,
            rx: rx
        )
    }
}
