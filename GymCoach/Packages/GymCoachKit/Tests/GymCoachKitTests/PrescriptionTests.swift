import XCTest
@testable import GymCoachKit

final class PrescriptionTests: XCTestCase {
    func testPhaseLiftsFollowThePhase() {
        let squat = Exercise(id: "squat", name: "Squat", prescription: .phase, tracksWeight: true)
        XCTAssertEqual(squat.target(in: .foundation).sets, 3)
        XCTAssertEqual(squat.target(in: .foundation).repHigh, 12)
        XCTAssertEqual(squat.target(in: .strength).sets, 4)
        XCTAssertEqual(squat.target(in: .strength).repLow, 6)
        XCTAssertEqual(squat.target(in: .deload).sets, 2)
        XCTAssertEqual(squat.target(in: .power).repHigh, 6)
        XCTAssertEqual(squat.target(in: .power).restSeconds, 120)
    }

    func testDeloadHalvesFixedSetsRoundingUp() {
        let calf = Exercise(id: "calf", name: "Calf raise", prescription: .fixed(sets: 3, reps: 15))
        XCTAssertEqual(calf.target(in: .strength).sets, 3)
        XCTAssertEqual(calf.target(in: .deload).sets, 2)

        let wrist = Exercise(id: "wrist", name: "Wrist curl", prescription: .fixed(sets: 2, reps: 15))
        XCTAssertEqual(wrist.target(in: .deload).sets, 1)
    }

    func testRoundsChangeByPhase() {
        let intervals = Exercise(id: "int", name: "Intervals",
                                 prescription: .rounds(foundation: 6, strength: 8, deload: 3, power: 6,
                                                       workSeconds: 30, restSeconds: 90))
        XCTAssertEqual(intervals.target(in: .strength).sets, 8)
        XCTAssertEqual(intervals.target(in: .deload).sets, 3)
        XCTAssertEqual(intervals.target(in: .foundation).seconds, 30)
        XCTAssertEqual(intervals.target(in: .foundation).restSeconds, 90)
    }

    func testDescriptions() {
        let split = Exercise(id: "s", name: "Split squat", prescription: .phase, perSide: true)
        XCTAssertEqual(split.targetDescription(in: .strength), "4 × 6–8 reps each side")

        let plank = Exercise(id: "p", name: "Plank", prescription: .timed(sets: 3, seconds: 20), perSide: true)
        XCTAssertEqual(plank.targetDescription(in: .foundation), "3 × 20 s each side")

        let sprint = Exercise(id: "r", name: "Sprint", prescription: .fixed(sets: 6, reps: 1), unitLabel: "10 m sprint")
        XCTAssertEqual(sprint.targetDescription(in: .foundation), "6 × 10 m sprint")
    }
}
