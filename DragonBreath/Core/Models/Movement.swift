import SwiftData
import Foundation

// MARK: - Movement

@Model
final class Movement {
    var id: UUID
    var name: String
    var category: MovementCategory
    var scoreTypes: [ScoreType]

    @Relationship(deleteRule: .nullify, inverse: \Workout.movements)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \LiftLog.movement)
    var liftLogs: [LiftLog] = []

    init(name: String, category: MovementCategory, scoreTypes: [ScoreType] = [.weight]) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.scoreTypes = scoreTypes
    }
}

// Stated explicitly so the conformance doesn't depend on @Model's macro expansion
// order; files elsewhere extend these models, which can otherwise hide it.
extension Movement: Identifiable {}
