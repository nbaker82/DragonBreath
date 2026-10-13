import SwiftUI

// MARK: - Lift Log List ViewModel

@Observable
final class LiftLogViewModel {
    var selectedMovement: Movement? = nil
    var searchText: String = ""
    var startDate: Date? = nil
    var endDate: Date? = nil

    func filtered(_ logs: [LiftLog]) -> [LiftLog] {
        LiftFilterLogic.apply(
            to: logs,
            movementID: selectedMovement?.id,
            searchText: searchText,
            startDate: startDate,
            endDate: endDate
        )
    }
}

// MARK: - Log Lift ViewModel

@Observable
final class LogLiftViewModel {
    var movement: Movement?
    var date: Date = Date()
    var sets: [LiftSet] = []
    var notes: String = ""
    var unit: WeightUnit = .lbs

    init(movement: Movement? = nil) {
        self.movement = movement
        addSet()
    }

    func addSet() {
        let newSet = LiftSet(
            setNumber: sets.count + 1,
            reps: nil,
            weight: sets.last?.weight
        )
        sets.append(newSet)
    }

    func removeSet(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
        for (i, set) in sets.enumerated() {
            set.setNumber = i + 1
        }
    }

    /// Next set number that would be assigned.
    var nextSetNumber: Int { sets.count + 1 }

    /// Max weight entered across all current sets.
    var currentMaxWeight: Double? {
        sets.compactMap { $0.weight }.max()
    }

    func percentileLabel(logs: [LiftLog]) -> String {
        guard let movement, let maxWeight = currentMaxWeight else { return "" }
        return LiftFilterLogic.percentileLabel(
            weight: maxWeight,
            movementID: movement.id,
            logs: logs
        )
    }

    func save(repo: LiftRepository) {
        guard let movement else { return }
        let log = LiftLog(
            movement: movement,
            date: date,
            sets: sets,
            notes: notes,
            unit: unit
        )
        repo.save(log)
    }
}
