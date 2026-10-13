import SwiftUI
import SwiftData
import Charts
import GymCoachKit

/// Your heaviest set for one exercise, session by session.
struct ProgressChartView: View {
    @Query(sort: \SessionRecord.startedAt) private var records: [SessionRecord]
    @State private var exerciseID = "a.squat"

    private struct Point: Identifiable {
        let date: Date
        let weight: Double
        var id: Date { date }
    }

    private var weightedExercises: [Exercise] {
        CricketPlan.days.flatMap(\.exercises).filter(\.tracksWeight)
    }

    private var sessions: [LoggedSession] {
        records.compactMap(\.session)
    }

    private var points: [Point] {
        sessions.compactMap { session in
            session.topWeight(for: exerciseID).map { Point(date: session.startedAt, weight: $0) }
        }
    }

    private var unitSymbol: String {
        sessions.last?.unit.symbol ?? WeightUnit.lb.symbol
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Exercise", selection: $exerciseID) {
                    ForEach(weightedExercises) { exercise in
                        Text(exercise.name).tag(exercise.id)
                    }
                }

                Section("Top set (\(unitSymbol))") {
                    if points.isEmpty {
                        Text("Log this exercise on your watch to see your progress here.")
                            .foregroundStyle(.secondary)
                    } else {
                        Chart(points) { point in
                            LineMark(x: .value("Date", point.date), y: .value("Weight", point.weight))
                                .interpolationMethod(.linear)
                            PointMark(x: .value("Date", point.date), y: .value("Weight", point.weight))
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .frame(height: 220)

                        if let first = points.first, let last = points.last, points.count > 1 {
                            let change = last.weight - first.weight
                            Text("\(change >= 0 ? "+" : "")\(change.formatted()) \(unitSymbol) since \(first.date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.footnote)
                                .foregroundStyle(change >= 0 ? Color.green : Color.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Progress")
        }
    }
}
