import Foundation
import SwiftData

/// One entry in `workouts.json`. Flags are omitted from the JSON when false.
struct WorkoutSeed: Decodable {
    let name: String
    let type: WorkoutType
    let description: String
    let timeCap: Int?
    let isBenchmark: Bool?
    let isHero: Bool?
    let isOpen: Bool?
    /// Movement names, matching `MovementSeed.name`.
    let movements: [String]
}
