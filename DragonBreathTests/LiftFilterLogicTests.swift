import XCTest
@testable import DragonBreath

// MARK: - Test Double

private struct StubLiftLog: LiftLoggable {
    var movementID: UUID?
    var movementName: String?
    var date: Date
    var maxWeight: Double?
}

// MARK: - Tests

final class LiftFilterLogicTests: XCTestCase {

    private let squat    = UUID()
    private let deadlift = UUID()

    private func makeLog(
        movementID: UUID? = nil,
        movementName: String? = nil,
        date: Date = Date(),
        maxWeight: Double? = nil
    ) -> StubLiftLog {
        StubLiftLog(movementID: movementID, movementName: movementName, date: date, maxWeight: maxWeight)
    }

    // MARK: Movement ID filter

    func test_movementID_keepsMatchingLogs() {
        let logs = [
            makeLog(movementID: squat,    movementName: "Back Squat"),
            makeLog(movementID: deadlift, movementName: "Deadlift"),
            makeLog(movementID: squat,    movementName: "Back Squat")
        ]
        let result = LiftFilterLogic.apply(to: logs, movementID: squat, searchText: "", startDate: nil, endDate: nil)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.movementID == squat })
    }

    func test_movementID_nil_returnsAll() {
        let logs = [
            makeLog(movementID: squat),
            makeLog(movementID: deadlift)
        ]
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "", startDate: nil, endDate: nil)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: Search text

    func test_searchText_matchesMovementName() {
        let logs = [
            makeLog(movementName: "Back Squat"),
            makeLog(movementName: "Deadlift")
        ]
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "squat", startDate: nil, endDate: nil)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.movementName, "Back Squat")
    }

    func test_searchText_empty_returnsAll() {
        let logs = [makeLog(movementName: "A"), makeLog(movementName: "B")]
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "", startDate: nil, endDate: nil)
        XCTAssertEqual(result.count, 2)
    }

    func test_searchText_caseInsensitive() {
        let logs = [makeLog(movementName: "Back Squat")]
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "BACK", startDate: nil, endDate: nil)
        XCTAssertEqual(result.count, 1)
    }

    // MARK: Date range filter

    func test_startDate_excludesOlderLogs() {
        let base = Date()
        let logs = [
            makeLog(date: base.addingTimeInterval(-86400 * 7)),  // 7 days ago
            makeLog(date: base.addingTimeInterval(-86400 * 3)),  // 3 days ago
            makeLog(date: base)                                   // today
        ]
        let cutoff = base.addingTimeInterval(-86400 * 4) // 4 days ago
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "", startDate: cutoff, endDate: nil)
        XCTAssertEqual(result.count, 2)
    }

    func test_endDate_excludesNewerLogs() {
        let base = Date()
        let logs = [
            makeLog(date: base.addingTimeInterval(-86400 * 2)),
            makeLog(date: base)
        ]
        let cutoff = base.addingTimeInterval(-86400 * 1) // yesterday
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "", startDate: nil, endDate: cutoff)
        XCTAssertEqual(result.count, 1)
    }

    func test_dateRange_bothBounds() {
        let base = Date()
        let logs = [
            makeLog(date: base.addingTimeInterval(-86400 * 10)),
            makeLog(date: base.addingTimeInterval(-86400 * 5)),
            makeLog(date: base.addingTimeInterval(-86400 * 2)),
            makeLog(date: base)
        ]
        let start = base.addingTimeInterval(-86400 * 6)
        let end   = base.addingTimeInterval(-86400 * 1)
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "", startDate: start, endDate: end)
        XCTAssertEqual(result.count, 2)
    }

    // MARK: Sort order (always newest first)

    func test_result_isSortedNewestFirst() {
        let base = Date()
        let logs = [
            makeLog(date: base.addingTimeInterval(-200)),
            makeLog(date: base),
            makeLog(date: base.addingTimeInterval(-100))
        ]
        let result = LiftFilterLogic.apply(to: logs, movementID: nil, searchText: "", startDate: nil, endDate: nil)
        XCTAssertTrue(zip(result, result.dropFirst()).allSatisfy { $0.date >= $1.date })
    }

    // MARK: Personal best

    func test_personalBest_returnsMaxWeight() {
        let logs = [
            makeLog(movementID: squat, maxWeight: 135),
            makeLog(movementID: squat, maxWeight: 225),
            makeLog(movementID: squat, maxWeight: 185)
        ]
        let pb = LiftFilterLogic.personalBest(movementID: squat, in: logs)
        XCTAssertEqual(pb, 225)
    }

    func test_personalBest_noLogsForMovement_returnsNil() {
        let logs = [makeLog(movementID: deadlift, maxWeight: 300)]
        let pb = LiftFilterLogic.personalBest(movementID: squat, in: logs)
        XCTAssertNil(pb)
    }

    func test_personalBest_ignoresOtherMovements() {
        let logs = [
            makeLog(movementID: squat,    maxWeight: 225),
            makeLog(movementID: deadlift, maxWeight: 400)
        ]
        let pb = LiftFilterLogic.personalBest(movementID: squat, in: logs)
        XCTAssertEqual(pb, 225)
    }

    // MARK: Percentile label

    func test_percentileLabel_firstLog_returnsFirstLogMessage() {
        let logs = [makeLog(movementID: squat, maxWeight: 135)]
        let label = LiftFilterLogic.percentileLabel(weight: 135, movementID: squat, logs: logs)
        XCTAssertEqual(label, "First Log!")
    }

    func test_percentileLabel_newPR() {
        let logs = [
            makeLog(movementID: squat, maxWeight: 135),
            makeLog(movementID: squat, maxWeight: 185)
        ]
        let label = LiftFilterLogic.percentileLabel(weight: 225, movementID: squat, logs: logs)
        XCTAssertEqual(label, "🏆 New PR!")
    }

    func test_percentileLabel_belowAverage() {
        let logs = (1...10).map { makeLog(movementID: squat, maxWeight: Double($0 * 20)) }
        let label = LiftFilterLogic.percentileLabel(weight: 20, movementID: squat, logs: logs)
        XCTAssertEqual(label, "Keep grinding 💪")
    }

    func test_percentileLabel_ignoresOtherMovements() {
        let logs = [
            makeLog(movementID: deadlift, maxWeight: 400),
            makeLog(movementID: squat,    maxWeight: 135)
        ]
        // Only 1 squat log → "First Log!"
        let label = LiftFilterLogic.percentileLabel(weight: 135, movementID: squat, logs: logs)
        XCTAssertEqual(label, "First Log!")
    }
}
