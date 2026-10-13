import XCTest
@testable import DragonBreath

final class FitnessRankTests: XCTestCase {

    // MARK: Rank thresholds

    func test_zeroSessions_isHouseCat() {
        XCTAssertEqual(FitnessRank.rank(for: 0), .houseCat)
    }

    func test_belowFoxThreshold_remainsHouseCat() {
        XCTAssertEqual(FitnessRank.rank(for: 14), .houseCat)
    }

    func test_atFoxThreshold_becomesFox() {
        XCTAssertEqual(FitnessRank.rank(for: 15), .fox)
    }

    func test_atWolfThreshold_becomesWolf() {
        XCTAssertEqual(FitnessRank.rank(for: 35), .wolf)
    }

    func test_atCheetahThreshold_becomesCheetah() {
        XCTAssertEqual(FitnessRank.rank(for: 75), .cheetah)
    }

    func test_atLionThreshold_becomesLion() {
        XCTAssertEqual(FitnessRank.rank(for: 150), .lion)
    }

    func test_atGrizzlyThreshold_becomesGrizzly() {
        XCTAssertEqual(FitnessRank.rank(for: 275), .grizzly)
    }

    func test_atPhoenixThreshold_becomesPhoenix() {
        XCTAssertEqual(FitnessRank.rank(for: 425), .phoenix)
    }

    func test_atGriffinThreshold_becomesGriffin() {
        XCTAssertEqual(FitnessRank.rank(for: 600), .griffin)
    }

    func test_atDragonThreshold_becomesDragon() {
        XCTAssertEqual(FitnessRank.rank(for: 850), .dragon)
    }

    func test_veryHighSessions_remainsDragon() {
        XCTAssertEqual(FitnessRank.rank(for: 9999), .dragon)
    }

    // MARK: Rank ordering

    func test_ranksAreStrictlyIncreasing() {
        let thresholds = FitnessRank.allCases.map(\.threshold)
        for (a, b) in zip(thresholds, thresholds.dropFirst()) {
            XCTAssertLessThan(a, b, "Each rank's threshold must be greater than the previous")
        }
    }

    func test_allCasesCount() {
        XCTAssertEqual(FitnessRank.allCases.count, 9)
    }

    // MARK: Mythical flag

    func test_houseCatThroughGrizzly_areNotMythical() {
        let nonMythical: [FitnessRank] = [.houseCat, .fox, .wolf, .cheetah, .lion, .grizzly]
        for rank in nonMythical {
            XCTAssertFalse(rank.isMythical, "\(rank.displayName) should not be mythical")
        }
    }

    func test_phoenixGriffinDragon_areMythical() {
        for rank in [FitnessRank.phoenix, .griffin, .dragon] {
            XCTAssertTrue(rank.isMythical, "\(rank.displayName) should be mythical")
        }
    }

    // MARK: Next rank

    func test_houseCat_nextIsFox() {
        XCTAssertEqual(FitnessRank.houseCat.next, .fox)
    }

    func test_dragon_nextIsNil() {
        XCTAssertNil(FitnessRank.dragon.next)
    }

    func test_eachRank_nextIsOneHigher() {
        for rank in FitnessRank.allCases.dropLast() {
            XCTAssertEqual(rank.next?.rawValue, rank.rawValue + 1)
        }
    }

    // MARK: Display names

    func test_displayNames_areNonEmpty() {
        for rank in FitnessRank.allCases {
            XCTAssertFalse(rank.displayName.isEmpty)
        }
    }

    func test_dragonDisplayName() {
        XCTAssertEqual(FitnessRank.dragon.displayName, "Dragon")
    }
}
