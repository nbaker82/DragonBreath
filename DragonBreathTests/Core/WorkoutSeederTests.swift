import XCTest
import SwiftData
@testable import DragonBreath

/// Checks that seeding stores every workout with all of its movements.
///
/// In the app, seeded workouts were losing some or all of their movement links; linking
/// after insertion fixed it there. These tests haven't reproduced that loss on their own,
/// so they guard the seeded data's shape rather than prove the fix.
@MainActor
final class WorkoutSeederTests: XCTestCase {

    /// A throwaway on-disk store, matching how the app persists data.
    private func makeContainer() throws -> ModelContainer {
        let url = FileManager.default.temporaryDirectory
            .appending(path: "SeederTest-\(UUID().uuidString).store")
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return try ModelContainer(
            for: Workout.self, Movement.self, WorkoutResult.self, LiftLog.self, LiftSet.self,
            configurations: ModelConfiguration(url: url)
        )
    }

    func test_seededWorkouts_keepAllTheirMovements() throws {
        let container = try makeContainer()
        WorkoutSeeder.seedIfNeeded(context: container.mainContext)

        // Read back through a fresh context so we see what was actually saved.
        let saved = try ModelContext(container).fetch(FetchDescriptor<Workout>())
        let expected = Dictionary(
            uniqueKeysWithValues: try SeedLibrary.load(from: .main).workouts.map { ($0.name, Set($0.movements)) }
        )

        XCTAssertEqual(saved.count, expected.count)
        for workout in saved {
            XCTAssertEqual(Set(workout.movements.map(\.name)), expected[workout.name], workout.name)
        }
    }

    func test_seeding_runsOnlyOnce() throws {
        let container = try makeContainer()
        WorkoutSeeder.seedIfNeeded(context: container.mainContext)
        WorkoutSeeder.seedIfNeeded(context: container.mainContext)

        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Workout>()), 51)
        XCTAssertEqual(try container.mainContext.fetchCount(FetchDescriptor<Movement>()), 134)
    }
}
