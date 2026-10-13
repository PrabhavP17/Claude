import Foundation

/// Works out which week, phase and workout day a date falls on.
///
/// The plan is a 9-week cycle: 3 weeks Foundation, 3 weeks Strength,
/// 1 week Deload, 2 weeks Power. After week 9 it starts again.
public struct PlanSchedule: Sendable {
    public static let cycle: [TrainingPhase] = [
        .foundation, .foundation, .foundation,
        .strength, .strength, .strength,
        .deload,
        .power, .power,
    ]

    /// Calendar weekday (Sunday = 1) to workout day id.
    public static let workoutDayByWeekday: [Int: String] = [2: "A", 3: "B", 5: "D", 6: "C"]

    public let startDate: Date
    public let calendar: Calendar

    public init(startDate: Date, calendar: Calendar = .current) {
        self.startDate = startDate
        self.calendar = calendar
    }

    /// The Fall 2026 block, starting Monday Oct 12, 2026.
    public static func fall2026(calendar: Calendar = .current) -> PlanSchedule {
        let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 12)) ?? Date()
        return PlanSchedule(startDate: start, calendar: calendar)
    }

    /// Week of the cycle, 1 through 9. Dates before the start count as week 1.
    public func weekNumber(on date: Date) -> Int {
        let days = calendar.dateComponents([.day],
                                           from: calendar.startOfDay(for: startDate),
                                           to: calendar.startOfDay(for: date)).day ?? 0
        guard days >= 0 else { return 1 }
        return (days / 7) % Self.cycle.count + 1
    }

    public func phase(on date: Date) -> TrainingPhase {
        Self.cycle[weekNumber(on: date) - 1]
    }

    /// The workout scheduled for that date, or nil on a rest day.
    public func workoutDayID(on date: Date) -> String? {
        Self.workoutDayByWeekday[calendar.component(.weekday, from: date)]
    }
}
