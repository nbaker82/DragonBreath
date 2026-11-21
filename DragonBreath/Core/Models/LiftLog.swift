import SwiftData
import Foundation

// MARK: - LiftLog

@Model
final class LiftLog {
    var id: UUID
    var movement: Movement?
    var date: Date
    @Relationship(deleteRule: .cascade) var sets: [LiftSet] = []
    var notes: String
    var unit: WeightUnit
    var programType: StrengthProgram?
    var percentageOf1RM: Double?

    init(
        movement: Movement,
        date: Date = Date(),
        sets: [LiftSet] = [],
        notes: String = "",
        unit: WeightUnit = .lbs,
        programType: StrengthProgram? = nil,
        percentageOf1RM: Double? = nil
    ) {
        self.id = UUID()
        self.movement = movement
        self.date = date
        self.sets = sets
        self.notes = notes
        self.unit = unit
        self.programType = programType
        self.percentageOf1RM = percentageOf1RM
    }

    var maxWeight: Double? {
        sets.compactMap { $0.weight }.max()
    }

    /// Max weight converted to `target`, so logs entered in different units can be compared.
    func maxWeight(in target: WeightUnit) -> Double? {
        maxWeight.map { unit.convert($0, to: target) }
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps ?? 0)) }
    }
}

// Stated explicitly so the conformance doesn't depend on @Model's macro expansion
// order; files elsewhere extend these models, which can otherwise hide it.
extension LiftLog: Identifiable {}
