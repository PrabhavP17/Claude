import SwiftUI
import GymCoachKit

struct PlanView: View {
    private let schedule = PlanSchedule.fall2026()

    var body: some View {
        let now = Date()
        let phase = schedule.phase(on: now)
        let today = schedule.workoutDayID(on: now).flatMap(CricketPlan.day(id:))

        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Week \(schedule.weekNumber(on: now)) of \(PlanSchedule.cycle.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(phase.title)
                            .font(.title2.bold())
                        Text(phase.summary)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Today") {
                    if let today {
                        NavigationLink {
                            DayDetailView(day: today, phase: phase)
                        } label: {
                            DaySummaryRow(day: today)
                        }
                    } else {
                        Label("Rest day. Recover well.", systemImage: "bed.double")
                    }
                }

                Section("The plan") {
                    ForEach(CricketPlan.days) { day in
                        NavigationLink {
                            DayDetailView(day: day, phase: phase)
                        } label: {
                            DaySummaryRow(day: day)
                        }
                    }
                }

                Section("Phases") {
                    ForEach(TrainingPhase.allCases, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title).font(.headline)
                            Text(item.summary).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Gym Coach")
        }
    }
}

private struct DaySummaryRow: View {
    let day: WorkoutDay

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(day.usualDay)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(day.title)
                .font(.headline)
        }
    }
}

struct DayDetailView: View {
    let day: WorkoutDay
    let phase: TrainingPhase

    var body: some View {
        List {
            Section {
                Text(day.focus)
            }
            Section("Warm-up") {
                ForEach(day.warmup, id: \.self) { Text($0) }
            }
            Section("Workout · \(phase.title)") {
                ForEach(day.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(exercise.name).font(.headline)
                        Text(exercise.targetDescription(in: phase))
                            .foregroundStyle(.green)
                        if !exercise.cue.isEmpty {
                            Text(exercise.cue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section("Cool-down") {
                ForEach(day.cooldown, id: \.self) { Text($0) }
            }
        }
        .navigationTitle(day.usualDay)
    }
}
