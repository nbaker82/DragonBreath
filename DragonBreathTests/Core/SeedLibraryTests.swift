import XCTest
@testable import DragonBreath

/// Guards the bundled seed JSON: it must decode, keep its size, and every
/// workout must reference movements that exist.
final class SeedLibraryTests: XCTestCase {

    private func loadLibrary() throws -> SeedLibrary {
        // Tests run inside the app host, so the app's resources are in Bundle.main.
        try SeedLibrary.load(from: .main)
    }

    func test_seedFiles_decode() throws {
        let library = try loadLibrary()
        XCTAssertEqual(library.movements.count, 134)
        XCTAssertEqual(library.workouts.count, 51)
    }

    func test_workouts_referenceKnownMovements() throws {
        XCTAssertEqual(try loadLibrary().unknownMovementReferences, [])
    }

    func test_movementNames_areUnique() throws {
        let names = try loadLibrary().movements.map(\.name)
        XCTAssertEqual(names.count, Set(names).count)
    }

    func test_benchmarkAndHeroCounts() throws {
        let workouts = try loadLibrary().workouts
        XCTAssertEqual(workouts.count { $0.isBenchmark == true }, 30)
        XCTAssertEqual(workouts.count { $0.isHero == true }, 21)
    }
}
