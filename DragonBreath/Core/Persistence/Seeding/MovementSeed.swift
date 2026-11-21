import Foundation

/// One entry in `movements.json`.
struct MovementSeed: Decodable {
    let name: String
    let category: MovementCategory
    let scoreTypes: [ScoreType]
}
