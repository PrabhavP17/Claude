import XCTest
@testable import GymCoachKit

final class ProgressionTests: XCTestCase {
    private let strength = TrainingPhase.strength.scheme
    private var target: SetTarget {
        SetTarget(sets: strength.sets, repLow: strength.repLow, repHigh: strength.repHigh,
                  seconds: nil, restSeconds: 120)
    }

    private func sets(_ pairs: [(Double, Int)]) -> [LoggedSet] {
        pairs.enumerated().map { index, pair in
            LoggedSet(exerciseID: "squat", setNumber: index + 1, reps: pair.1, weight: pair.0)
        }
    }

    func testNoHistoryMeansNoSuggestion() {
        XCTAssertNil(Progression.suggestedWeight(previous: [], target: target, phase: .strength, unit: .lb))
    }

    func testAddsWeightWhenEverySetHitsTheTopOfTheRange() {
        let previous = sets([(135, 8), (135, 8), (135, 8), (135, 9)])
        XCTAssertEqual(Progression.suggestedWeight(previous: previous, target: target, phase: .strength, unit: .lb), 140)
        XCTAssertEqual(Progression.suggestedWeight(previous: previous, target: target, phase: .strength, unit: .kg), 137.5)
    }

    func testStaysWhenASetFellShort() {
        let previous = sets([(135, 8), (135, 8), (135, 6), (135, 5)])
        XCTAssertEqual(Progression.suggestedWeight(previous: previous, target: target, phase: .strength, unit: .lb), 135)
    }

    func testOnlyTheTopWeightCounts() {
        // Warm-up style lighter sets with low reps don't block progress.
        let previous = sets([(95, 5), (135, 8), (135, 8)])
        XCTAssertEqual(Progression.suggestedWeight(previous: previous, target: target, phase: .strength, unit: .lb), 140)
    }

    func testDeloadKeepsTheSameWeight() {
        let previous = sets([(135, 8), (135, 8)])
        XCTAssertEqual(Progression.suggestedWeight(previous: previous, target: target, phase: .deload, unit: .lb), 135)
    }

    func testSessionTopWeight() {
        let session = LoggedSession(dayID: "A", phase: .strength, unit: .lb, startedAt: Date(), endedAt: Date(),
                                    sets: sets([(95, 10), (135, 8)]))
        XCTAssertEqual(session.topWeight(for: "squat"), 135)
        XCTAssertNil(session.topWeight(for: "bench"))
    }
}
