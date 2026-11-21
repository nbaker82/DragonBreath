import Foundation
import SwiftData

// MARK: - LiftLog: LiftLoggable

extension LiftLog: LiftLoggable {
    var movementID: UUID? { movement?.id }
    var movementName: String? { movement?.name }
}
