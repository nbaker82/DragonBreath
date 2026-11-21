import XCTest
@testable import DragonBreath

final class LogLiftViewModelTests: XCTestCase {

    // MARK: Initial state

    func test_init_startsWithOneSet() {
        let vm = LogLiftViewModel()
        XCTAssertEqual(vm.sets.count, 1)
    }

    func test_init_firstSetIsNumberOne() {
        let vm = LogLiftViewModel()
        XCTAssertEqual(vm.sets.first?.setNumber, 1)
    }

    func test_init_defaultUnit_isLbs() {
        let vm = LogLiftViewModel()
        XCTAssertEqual(vm.unit, .lbs)
    }

    // MARK: addSet

    func test_addSet_incrementsCount() {
        let vm = LogLiftViewModel()
        vm.addSet()
        XCTAssertEqual(vm.sets.count, 2)
    }

    func test_addSet_newSetHasCorrectSetNumber() {
        let vm = LogLiftViewModel()
        vm.addSet()
        XCTAssertEqual(vm.sets.last?.setNumber, 2)
    }

    func test_addSet_prefillsWeightFromLastSet() {
        let vm = LogLiftViewModel()
        vm.sets[0].weight = 135
        vm.addSet()
        XCTAssertEqual(vm.sets.last?.weight, 135)
    }

    func test_addSet_noWeightOnPrevious_newSetHasNilWeight() {
        let vm = LogLiftViewModel()
        vm.sets[0].weight = nil
        vm.addSet()
        XCTAssertNil(vm.sets.last?.weight)
    }

    // MARK: removeSet

    func test_removeSet_decreasesCount() {
        let vm = LogLiftViewModel()
        vm.addSet()
        vm.addSet()
        XCTAssertEqual(vm.sets.count, 3)
        vm.removeSet(at: IndexSet(integer: 0))
        XCTAssertEqual(vm.sets.count, 2)
    }

    func test_removeSet_renumbersRemainingSetsContinuously() {
        let vm = LogLiftViewModel()
        vm.addSet()
        vm.addSet()
        // Sets: 1, 2, 3 → remove index 1 → should become 1, 2
        vm.removeSet(at: IndexSet(integer: 1))
        let numbers = vm.sets.map(\.setNumber)
        XCTAssertEqual(numbers, [1, 2])
    }

    func test_removeSet_removingFirstSet_renumbers() {
        let vm = LogLiftViewModel()
        vm.addSet()
        // Sets: 1, 2 → remove first → should become 1
        vm.removeSet(at: IndexSet(integer: 0))
        XCTAssertEqual(vm.sets.count, 1)
        XCTAssertEqual(vm.sets[0].setNumber, 1)
    }

    // MARK: nextSetNumber

    func test_nextSetNumber_afterInit_isTwo() {
        let vm = LogLiftViewModel()
        XCTAssertEqual(vm.nextSetNumber, 2)
    }

    func test_nextSetNumber_afterAddingThreeSets_isFour() {
        let vm = LogLiftViewModel()
        vm.addSet()
        vm.addSet()
        XCTAssertEqual(vm.nextSetNumber, 4)
    }

    // MARK: currentMaxWeight

    func test_currentMaxWeight_noWeights_returnsNil() {
        let vm = LogLiftViewModel()
        XCTAssertNil(vm.currentMaxWeight)
    }

    func test_currentMaxWeight_singleSet_returnsThatWeight() {
        let vm = LogLiftViewModel()
        vm.sets[0].weight = 185
        XCTAssertEqual(vm.currentMaxWeight, 185)
    }

    func test_currentMaxWeight_multipleSets_returnsMax() {
        let vm = LogLiftViewModel()
        vm.sets[0].weight = 135
        vm.addSet()
        vm.sets[1].weight = 185
        vm.addSet()
        vm.sets[2].weight = 165
        XCTAssertEqual(vm.currentMaxWeight, 185)
    }

    func test_currentMaxWeight_someSetsNil_ignoresNils() {
        let vm = LogLiftViewModel()
        vm.sets[0].weight = nil
        vm.addSet()
        vm.sets[1].weight = 225
        XCTAssertEqual(vm.currentMaxWeight, 225)
    }
}
