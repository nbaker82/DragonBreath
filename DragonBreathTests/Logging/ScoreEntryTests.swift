import XCTest
@testable import DragonBreath

final class ScoreEntryTests: XCTestCase {

    func test_timedWorkout_combinesMinutesAndSeconds() {
        let entry = ScoreEntry(minutes: "4", seconds: "35")
        XCTAssertEqual(entry.score(for: .forTime), WorkoutScore(scoreType: .time, timeSeconds: 275))
    }

    func test_timedWorkout_emptyFieldsCountAsZero() {
        XCTAssertEqual(ScoreEntry().score(for: .chipper).timeSeconds, 0)
    }

    func test_seconds_over59_isInvalidOnlyForTimedWorkouts() {
        let entry = ScoreEntry(seconds: "75")
        XCTAssertTrue(entry.secondsAreInvalid(for: .rft))
        XCTAssertFalse(entry.secondsAreInvalid(for: .amrap))
        XCTAssertFalse(ScoreEntry(seconds: "59").secondsAreInvalid(for: .forTime))
    }

    func test_roundsWorkouts_storeRoundsAndReps() {
        let entry = ScoreEntry(rounds: "7", reps: "12")
        for type in [WorkoutType.amrap, .emom, .deathBy] {
            XCTAssertEqual(entry.score(for: type), WorkoutScore(scoreType: .rounds, rounds: 7, repsRemainder: 12))
        }
    }

    func test_tabata_storesTotalReps() {
        XCTAssertEqual(ScoreEntry(totalReps: "143").score(for: .tabata), WorkoutScore(scoreType: .reps, totalReps: 143))
    }

    func test_strength_parsesDecimalWeight() {
        XCTAssertEqual(ScoreEntry(weight: "102.5").score(for: .maxLoad).weight, 102.5)
    }

    func test_freeFormTypes_storeNoNumbers() {
        XCTAssertEqual(ScoreEntry(rounds: "3").score(for: .intervals), WorkoutScore(scoreType: .reps))
    }
}
