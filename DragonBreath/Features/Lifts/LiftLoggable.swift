import Foundation

// MARK: - Protocol

/// Describes the properties LiftFilterLogic needs from a lift log.
protocol LiftLoggable {
    var movementID: UUID? { get }
    var movementName: String? { get }
    var date: Date { get }
    var maxWeight: Double? { get }
    /// Unit that `maxWeight` was entered in.
    var unit: WeightUnit { get }
}

extension LiftLoggable {
    /// Max weight normalized to pounds so logs in different units compare correctly.
    var maxWeightLbs: Double? { maxWeight.map { unit.convert($0, to: .lbs) } }
}
