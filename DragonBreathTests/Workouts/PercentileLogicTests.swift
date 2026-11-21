import XCTest
@testable import DragonBreath

// MARK: - Test Double

private struct StubResult: WorkoutResultScoring {
    var timeSeconds: Int?
    var rounds: Int?
    var repsRemainder: Int?
    var weight: Double?
    var totalReps: Int?
}

// MARK: - Tests

final class PercentileLogicTests: XCTestCase {

    // MARK: Single result → always PR

    func test_singleResult_returnsFullPercentile() {
        let result = StubResult(timeSeconds: 300)
        let pct = PercentileLogic.percentile(for: result, in: [result], workoutType: .forTime)
        XCTAssertEqual(pct, 1.0)
    }

    // MARK: For Time (lower = better)

    func test_forTime_fastestTime_isHighestPercentile() {
        let fastest = StubResult(timeSeconds: 180)
        let middle  = StubResult(timeSeconds: 240)
        let slowest = StubResult(timeSeconds: 300)
        let all = [fastest, middle, slowest]

        let pct = PercentileLogic.percentile(for: fastest, in: all, workoutType: .forTime)
        XCTAssertEqual(pct, 1.0, "Fastest time should be 100th percentile")
    }

    func test_forTime_slowestTime_isLowestPercentile() {
        let fastest = StubResult(timeSeconds: 180)
        let middle  = StubResult(timeSeconds: 240)
        let slowest = StubResult(timeSeconds: 300)
        let all = [fastest, middle, slowest]

        let pct = PercentileLogic.percentile(for: slowest, in: all, workoutType: .forTime)
        XCTAssertEqual(pct, Double(1) / 3.0, accuracy: 0.01)
    }

    func test_forTime_middleTime_isMidPercentile() {
        let fastest = StubResult(timeSeconds: 180)
        let middle  = StubResult(timeSeconds: 240)
        let slowest = StubResult(timeSeconds: 300)
        let all = [fastest, middle, slowest]

        let pct = PercentileLogic.percentile(for: middle, in: all, workoutType: .forTime)
        XCTAssertEqual(pct, Double(2) / 3.0, accuracy: 0.01)
    }

    func test_forTime_missingTimeSeconds_returnsZero() {
        let noTime = StubResult(timeSeconds: nil)
        let other  = StubResult(timeSeconds: 300)
        let pct = PercentileLogic.percentile(for: noTime, in: [noTime, other], workoutType: .forTime)
        XCTAssertEqual(pct, 0)
    }

    // MARK: AMRAP (higher rounds+reps = better)

    func test_amrap_highestScore_isFullPercentile() {
        let best   = StubResult(rounds: 10, repsRemainder: 5)
        let middle = StubResult(rounds: 8,  repsRemainder: 0)
        let worst  = StubResult(rounds: 5,  repsRemainder: 3)
        let all = [best, middle, worst]

        let pct = PercentileLogic.percentile(for: best, in: all, workoutType: .amrap)
        XCTAssertEqual(pct, 1.0)
    }

    func test_amrap_lowestScore_isLowestPercentile() {
        let best   = StubResult(rounds: 10, repsRemainder: 0)
        let middle = StubResult(rounds: 8,  repsRemainder: 0)
        let worst  = StubResult(rounds: 5,  repsRemainder: 0)
        let all = [best, middle, worst]

        let pct = PercentileLogic.percentile(for: worst, in: all, workoutType: .amrap)
        XCTAssertEqual(pct, Double(1) / 3.0, accuracy: 0.01)
    }

    func test_amrap_repsRemainder_breaksRoundsTie() {
        let higherReps = StubResult(rounds: 8, repsRemainder: 10)
        let lowerReps  = StubResult(rounds: 8, repsRemainder: 2)
        let all = [higherReps, lowerReps]

        let pct = PercentileLogic.percentile(for: higherReps, in: all, workoutType: .amrap)
        XCTAssertGreaterThan(pct, PercentileLogic.percentile(for: lowerReps, in: all, workoutType: .amrap))
    }

    // MARK: Max Load (higher weight = better)

    func test_maxLoad_heaviestWeight_isFullPercentile() {
        let heavy  = StubResult(weight: 225)
        let medium = StubResult(weight: 185)
        let light  = StubResult(weight: 135)
        let all = [heavy, medium, light]

        let pct = PercentileLogic.percentile(for: heavy, in: all, workoutType: .maxLoad)
        XCTAssertEqual(pct, 1.0)
    }

    func test_maxLoad_lightestWeight_isLowestPercentile() {
        let heavy  = StubResult(weight: 225)
        let medium = StubResult(weight: 185)
        let light  = StubResult(weight: 135)
        let all = [heavy, medium, light]

        let pct = PercentileLogic.percentile(for: light, in: all, workoutType: .maxLoad)
        XCTAssertEqual(pct, Double(1) / 3.0, accuracy: 0.01)
    }

    func test_maxLoad_missingWeight_returnsZero() {
        let noWeight = StubResult(weight: nil)
        let other    = StubResult(weight: 200)
        let pct = PercentileLogic.percentile(for: noWeight, in: [noWeight, other], workoutType: .maxLoad)
        XCTAssertEqual(pct, 0)
    }

    // MARK: Tabata

    func test_tabata_highestReps_isFullPercentile() {
        let high   = StubResult(totalReps: 120)
        let medium = StubResult(totalReps: 100)
        let low    = StubResult(totalReps: 80)
        let all = [high, medium, low]

        let pct = PercentileLogic.percentile(for: high, in: all, workoutType: .tabata)
        XCTAssertEqual(pct, 1.0)
    }

    // MARK: Percentile labels

    func test_label_pr() {
        XCTAssertEqual(PercentileLogic.label(for: 1.0), "🏆 PR")
    }

    func test_label_top10() {
        XCTAssertEqual(PercentileLogic.label(for: 0.95), "Top 10%")
    }

    func test_label_top25() {
        XCTAssertEqual(PercentileLogic.label(for: 0.80), "Top 25%")
    }

    func test_label_top50() {
        XCTAssertEqual(PercentileLogic.label(for: 0.60), "Top 50%")
    }

    func test_label_bottom50() {
        XCTAssertEqual(PercentileLogic.label(for: 0.40), "Bottom 50%")
    }

    // MARK: Personal best index

    func test_personalBest_forTime_findsFastest() {
        let results = [
            StubResult(timeSeconds: 300),
            StubResult(timeSeconds: 180),
            StubResult(timeSeconds: 240)
        ]
        let idx = PercentileLogic.personalBestIndex(in: results, workoutType: .forTime)
        XCTAssertEqual(idx, 1, "Index 1 has the fastest time (180s)")
    }

    func test_personalBest_amrap_findsHighestRounds() {
        let results = [
            StubResult(rounds: 5, repsRemainder: 0),
            StubResult(rounds: 10, repsRemainder: 3),
            StubResult(rounds: 10, repsRemainder: 0)
        ]
        let idx = PercentileLogic.personalBestIndex(in: results, workoutType: .amrap)
        XCTAssertEqual(idx, 1, "Index 1 has 10+3 which beats 10+0")
    }

    func test_personalBest_maxLoad_findsHeaviest() {
        let results = [
            StubResult(weight: 135),
            StubResult(weight: 225),
            StubResult(weight: 185)
        ]
        let idx = PercentileLogic.personalBestIndex(in: results, workoutType: .maxLoad)
        XCTAssertEqual(idx, 1, "Index 1 has the heaviest weight (225)")
    }

    func test_personalBest_emptyResults_returnsNil() {
        let idx = PercentileLogic.personalBestIndex(in: [StubResult](), workoutType: .forTime)
        XCTAssertNil(idx)
    }
}
