import XCTest
@testable import DragonBreath

// MARK: - Test Double

private struct StubWorkout: WorkoutFilterable {
    var name: String
    var workoutDescription: String = ""
    var workoutType: WorkoutType = .amrap
    var isBenchmark: Bool = false
    var createdAt: Date = Date()
    var movementIDs: [UUID] = []
}

// MARK: - Tests

final class WorkoutFilterLogicTests: XCTestCase {

    // MARK: Search text

    func test_searchText_matchesName() {
        let workouts = [StubWorkout(name: "Fran"), StubWorkout(name: "Helen")]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "fran",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["Fran"])
    }

    func test_searchText_matchesDescription() {
        let workouts = [
            StubWorkout(name: "WOD1", workoutDescription: "Thrusters and pull-ups"),
            StubWorkout(name: "WOD2", workoutDescription: "Box jumps and burpees")
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "thruster",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["WOD1"])
    }

    func test_searchText_empty_returnsAll() {
        let workouts = [StubWorkout(name: "A"), StubWorkout(name: "B")]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.count, 2)
    }

    func test_searchText_noMatch_returnsEmpty() {
        let workouts = [StubWorkout(name: "Fran")]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "Murph",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: Workout type filter

    func test_workoutTypeFilter_keepsMatchingType() {
        let workouts = [
            StubWorkout(name: "A", workoutType: .amrap),
            StubWorkout(name: "B", workoutType: .forTime),
            StubWorkout(name: "C", workoutType: .amrap)
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: .amrap, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["A", "C"])
    }

    func test_workoutTypeFilter_nil_returnsAll() {
        let workouts = [
            StubWorkout(name: "A", workoutType: .amrap),
            StubWorkout(name: "B", workoutType: .forTime)
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.count, 2)
    }

    // MARK: Movement filter

    func test_movementFilter_keepsWorkoutsContainingMovement() {
        let targetID = UUID()
        let otherID  = UUID()
        let workouts = [
            StubWorkout(name: "A", movementIDs: [targetID]),
            StubWorkout(name: "B", movementIDs: [otherID]),
            StubWorkout(name: "C", movementIDs: [targetID, otherID])
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: targetID,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["A", "C"])
    }

    func test_movementFilter_nil_returnsAll() {
        let workouts = [StubWorkout(name: "A"), StubWorkout(name: "B")]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.count, 2)
    }

    // MARK: Benchmark filter

    func test_benchmarksOnly_filterNonBenchmarks() {
        let workouts = [
            StubWorkout(name: "Fran", isBenchmark: true),
            StubWorkout(name: "Custom", isBenchmark: false)
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: true, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["Fran"])
    }

    func test_benchmarksOnly_false_returnsAll() {
        let workouts = [
            StubWorkout(name: "Fran", isBenchmark: true),
            StubWorkout(name: "Custom", isBenchmark: false)
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.count, 2)
    }

    // MARK: Sort orders

    func test_sortOrder_nameAscending() {
        let workouts = [StubWorkout(name: "Charlie"), StubWorkout(name: "Alpha"), StubWorkout(name: "Bravo")]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["Alpha", "Bravo", "Charlie"])
    }

    func test_sortOrder_nameDescending() {
        let workouts = [StubWorkout(name: "Alpha"), StubWorkout(name: "Charlie"), StubWorkout(name: "Bravo")]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameDescending
        )
        XCTAssertEqual(result.map(\.name), ["Charlie", "Bravo", "Alpha"])
    }

    func test_sortOrder_newest() {
        let base = Date()
        let workouts = [
            StubWorkout(name: "Old",    createdAt: base.addingTimeInterval(-200)),
            StubWorkout(name: "Newest", createdAt: base.addingTimeInterval(0)),
            StubWorkout(name: "Middle", createdAt: base.addingTimeInterval(-100))
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .newest
        )
        XCTAssertEqual(result.map(\.name), ["Newest", "Middle", "Old"])
    }

    func test_sortOrder_oldest() {
        let base = Date()
        let workouts = [
            StubWorkout(name: "Newest", createdAt: base),
            StubWorkout(name: "Old",    createdAt: base.addingTimeInterval(-200)),
            StubWorkout(name: "Middle", createdAt: base.addingTimeInterval(-100))
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "",
            workoutType: nil, movementID: nil,
            benchmarksOnly: false, sortOrder: .oldest
        )
        XCTAssertEqual(result.map(\.name), ["Old", "Middle", "Newest"])
    }

    // MARK: Combined filters

    func test_searchAndType_combined() {
        let workouts = [
            StubWorkout(name: "Fran",   workoutType: .forTime, isBenchmark: true),
            StubWorkout(name: "Helen",  workoutType: .forTime, isBenchmark: true),
            StubWorkout(name: "My WOD", workoutType: .amrap,   isBenchmark: false)
        ]
        let result = WorkoutFilterLogic.apply(
            to: workouts, searchText: "fran",
            workoutType: .forTime, movementID: nil,
            benchmarksOnly: false, sortOrder: .nameAscending
        )
        XCTAssertEqual(result.map(\.name), ["Fran"])
    }
}
