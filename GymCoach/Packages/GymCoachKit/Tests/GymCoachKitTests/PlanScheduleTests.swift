import XCTest
@testable import GymCoachKit

final class PlanScheduleTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Toronto")!
        return calendar
    }()

    private func date(_ month: Int, _ day: Int, hour: Int = 12, year: Int = 2026) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    func testPhasesMatchTheFall2026Plan() {
        let schedule = PlanSchedule.fall2026(calendar: calendar)
        XCTAssertEqual(schedule.phase(on: date(10, 15)), .foundation)
        XCTAssertEqual(schedule.phase(on: date(11, 1)), .foundation)
        XCTAssertEqual(schedule.phase(on: date(11, 2)), .strength)
        XCTAssertEqual(schedule.phase(on: date(11, 22)), .strength)
        XCTAssertEqual(schedule.phase(on: date(11, 23)), .deload)
        XCTAssertEqual(schedule.phase(on: date(11, 30)), .power)
        XCTAssertEqual(schedule.phase(on: date(12, 13)), .power)
    }

    func testCycleRestartsAfterNineWeeks() {
        let schedule = PlanSchedule.fall2026(calendar: calendar)
        XCTAssertEqual(schedule.weekNumber(on: date(12, 14)), 1)
        XCTAssertEqual(schedule.phase(on: date(12, 14)), .foundation)
    }

    func testDatesBeforeStartCountAsWeekOne() {
        let schedule = PlanSchedule.fall2026(calendar: calendar)
        XCTAssertEqual(schedule.weekNumber(on: date(9, 1)), 1)
    }

    func testWorkoutDaysByWeekday() {
        let schedule = PlanSchedule.fall2026(calendar: calendar)
        XCTAssertEqual(schedule.workoutDayID(on: date(10, 19)), "A") // Monday
        XCTAssertEqual(schedule.workoutDayID(on: date(10, 20)), "B") // Tuesday
        XCTAssertNil(schedule.workoutDayID(on: date(10, 21)))        // Wednesday: umpiring
        XCTAssertEqual(schedule.workoutDayID(on: date(10, 22)), "D") // Thursday
        XCTAssertEqual(schedule.workoutDayID(on: date(10, 23)), "C") // Friday
        XCTAssertNil(schedule.workoutDayID(on: date(10, 24)))        // Saturday
    }

    func testEveryScheduledDayExistsInThePlan() {
        for id in PlanSchedule.workoutDayByWeekday.values {
            XCTAssertNotNil(CricketPlan.day(id: id), "Missing day \(id)")
        }
    }

    func testExerciseIDsAreUnique() {
        let ids = CricketPlan.days.flatMap(\.exercises).map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }
}
