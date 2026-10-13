import SwiftUI
import GymCoachKit

/// Opens on today's workout. Any other day is one scroll away.
struct TodayView: View {
    @AppStorage("unit") private var unitRaw = WeightUnit.lb.rawValue
    @State private var activeDay: WorkoutDay?

    private let schedule = PlanSchedule.fall2026()

    var body: some View {
        let now = Date()
        let phase = schedule.phase(on: now)
        let today = schedule.workoutDayID(on: now).flatMap(CricketPlan.day(id:))

        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Week \(schedule.weekNumber(on: now)) · \(phase.title)")
                            .font(.headline)
                        Text(phase.summary)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Today") {
                    if let today {
                        Button { activeDay = today } label: {
                            DayRow(day: today, phase: phase)
                        }
                        .listItemTint(.green)
                    } else {
                        Text("Rest day. Recover well.")
                            .font(.footnote)
                    }
                }

                Section("Any workout") {
                    ForEach(CricketPlan.days) { day in
                        Button { activeDay = day } label: {
                            DayRow(day: day, phase: phase)
                        }
                    }
                }

                Section {
                    Picker("Units", selection: $unitRaw) {
                        ForEach(WeightUnit.allCases, id: \.rawValue) { unit in
                            Text(unit.symbol).tag(unit.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Gym Coach")
            .fullScreenCover(item: $activeDay) { day in
                WorkoutContainerView(day: day, phase: phase, unit: WeightUnit(rawValue: unitRaw) ?? .lb)
            }
        }
    }
}

private struct DayRow: View {
    let day: WorkoutDay
    let phase: TrainingPhase

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Day \(day.id) · \(day.usualDay)")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(day.title)
                .font(.headline)
            Text("\(day.exercises.count) exercises")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
