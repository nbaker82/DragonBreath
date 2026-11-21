import SwiftData
import Foundation

@Model
final class LiftSet {
    var id: UUID
    var setNumber: Int
    var reps: Int?
    var weight: Double?
    var distance: Double?   // meters
    var height: Double?     // inches
    var completed: Bool
    var isMax: Bool         // Rep max attempt

    init(
        setNumber: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        distance: Double? = nil,
        height: Double? = nil,
        isMax: Bool = false
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.distance = distance
        self.height = height
        self.completed = false
        self.isMax = isMax
    }
}

// Stated explicitly so the conformance doesn't depend on @Model's macro expansion
// order; files elsewhere extend these models, which can otherwise hide it.
extension LiftSet: Identifiable {}
