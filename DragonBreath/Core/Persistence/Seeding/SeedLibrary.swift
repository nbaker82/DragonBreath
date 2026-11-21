import Foundation
import SwiftData

/// The decoded contents of the bundled seed JSON files.
struct SeedLibrary {
    let movements: [MovementSeed]
    let workouts: [WorkoutSeed]

    static func load(from bundle: Bundle) throws -> SeedLibrary {
        SeedLibrary(
            movements: try decode([MovementSeed].self, resource: "movements", bundle: bundle),
            workouts: try decode([WorkoutSeed].self, resource: "workouts", bundle: bundle)
        )
    }

    /// Movement names referenced by workouts that don't exist in the movement list.
    var unknownMovementReferences: [String] {
        let known = Set(movements.map(\.name))
        return workouts.flatMap(\.movements).filter { !known.contains($0) }
    }

    private static func decode<T: Decodable>(_ type: T.Type, resource: String, bundle: Bundle) throws -> T {
        guard let url = bundle.url(forResource: resource, withExtension: "json") else {
            throw SeedError.missingResource(resource)
        }
        return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
    }
}
