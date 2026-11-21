import SwiftUI
import SwiftData

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
