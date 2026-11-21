import SwiftData
import Foundation

// MARK: - Workout

@Model
final class Workout {
    var id: UUID
    var name: String
    var workoutType: WorkoutType
    var workoutDescription: String
    var timeCap: Int?           // seconds, nil = no cap
    var isBenchmark: Bool       // named benchmark Girls (Fran, Helen, etc.)
    var isHero: Bool            // Hero WODs (Murph, Chad, etc.)
    var isOpen: Bool            // CrossFit Open workouts
    var createdAt: Date
    /// Assign only after the workout is inserted into a context. SwiftData can drop
    /// many-to-many links set on a model before insertion.
    var movements: [Movement] = []

    @Relationship(deleteRule: .cascade, inverse: \WorkoutResult.workout)
    var results: [WorkoutResult] = []

    init(
        name: String,
        workoutType: WorkoutType,
        workoutDescription: String,
        timeCap: Int? = nil,
        isBenchmark: Bool = false,
        isHero: Bool = false,
        isOpen: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.workoutType = workoutType
        self.workoutDescription = workoutDescription
        self.timeCap = timeCap
        self.isBenchmark = isBenchmark
        self.isHero = isHero
        self.isOpen = isOpen
        self.createdAt = Date()
    }
}

// Stated explicitly so the conformance doesn't depend on @Model's macro expansion
// order; files elsewhere extend these models, which can otherwise hide it.
extension Workout: Identifiable {}
