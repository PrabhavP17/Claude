import SwiftUI
import SwiftData
import GymCoachKit

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SessionRecord.startedAt, order: .reverse) private var records: [SessionRecord]

    var body: some View {
        NavigationStack {
            List {
                ForEach(records) { record in
                    if let session = record.session {
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            SessionRow(session: session)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets { context.delete(records[index]) }
                    try? context.save()
                }
            }
            .overlay {
                if records.isEmpty {
                    ContentUnavailableView("No workouts yet", systemImage: "applewatch",
                                           description: Text("Finish a workout on your watch and it shows up here."))
                }
            }
            .navigationTitle("History")
        }
    }
}

private struct SessionRow: View {
    let session: LoggedSession

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(CricketPlan.day(id: session.dayID)?.displayName ?? "Day \(session.dayID)")
                .font(.headline)
            Text("\(session.startedAt.formatted(date: .abbreviated, time: .shortened)) · \(session.phase.title)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(session.sets.count) sets · \(Int(session.duration / 60)) min")
                .font(.caption)
        }
    }
}

struct SessionDetailView: View {
    let session: LoggedSession

    private var exerciseIDs: [String] {
        var seen = Set<String>()
        return session.sets.map(\.exerciseID).filter { seen.insert($0).inserted }
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Phase", value: session.phase.title)
                LabeledContent("Duration", value: "\(Int(session.duration / 60)) min")
                if let heartRate = session.averageHeartRate {
                    LabeledContent("Average heart rate", value: "\(Int(heartRate)) bpm")
                }
                if let calories = session.activeCalories {
                    LabeledContent("Active calories", value: "\(Int(calories)) kcal")
                }
            }
            ForEach(exerciseIDs, id: \.self) { id in
                Section(CricketPlan.exercise(id: id)?.name ?? id) {
                    ForEach(session.sets(for: id), id: \.self) { set in
                        Text(describe(set))
                            .monospacedDigit()
                    }
                }
            }
        }
        .navigationTitle(session.startedAt.formatted(date: .abbreviated, time: .omitted))
    }

    private func describe(_ set: LoggedSet) -> String {
        var text = "Set \(set.setNumber): "
        if let seconds = set.seconds {
            text += "\(seconds) s"
        } else {
            text += "\(set.reps) reps"
        }
        if let weight = set.weight, weight > 0 {
            text += " × \(weight.formatted()) \(session.unit.symbol)"
        }
        return text
    }
}
