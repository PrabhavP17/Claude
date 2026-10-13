import SwiftUI
import SwiftData
import GymCoachKit

/// Owns one workout from start to summary.
struct WorkoutContainerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var model: WorkoutModel
    @State private var health = HealthWorkoutManager()
    @State private var isFinishing = false
    @State private var saved: LoggedSession?

    init(day: WorkoutDay, phase: TrainingPhase, unit: WeightUnit) {
        _model = State(initialValue: WorkoutModel(day: day, phase: phase, unit: unit))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let saved {
                    SummaryView(session: saved, day: model.day) { dismiss() }
                } else {
                    switch model.stage {
                    case .active:
                        ExerciseView(model: model, heartRate: health.heartRate)
                    case .resting(let until):
                        RestView(until: until, upNext: model.upNext, heartRate: health.heartRate) {
                            model.skipRest()
                        }
                    case .finished:
                        ProgressView("Saving…")
                    }
                }
            }
            .toolbar {
                if saved == nil {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("End") { Task { await finish() } }
                    }
                }
            }
        }
        .task {
            model.begin { [context] exerciseID in
                SessionStore.lastSets(for: exerciseID, in: context)
            }
            await health.start(activity: model.day.isConditioning
                               ? .highIntensityIntervalTraining
                               : .traditionalStrengthTraining)
        }
        .onChange(of: model.stage) { _, stage in
            if stage == .finished { Task { await finish() } }
        }
    }

    private func finish() async {
        guard !isFinishing else { return }
        isFinishing = true
        model.finish()
        let summary = await health.end()
        let session = model.makeSession(summary: summary)
        if !session.sets.isEmpty {
            SessionStore.save(session, in: context)
            Connectivity.shared.send(session)
        }
        saved = session
    }
}

struct ExerciseView: View {
    @Bindable var model: WorkoutModel
    let heartRate: Double

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(model.exerciseIndex + 1)/\(model.totalExercises) · Set \(model.setIndex + 1) of \(model.target.sets)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(model.exercise.name)
                    .font(.headline)

                Text(model.exercise.targetDescription(in: model.phase))
                    .font(.caption)
                    .foregroundStyle(.green)

                if !model.exercise.cue.isEmpty {
                    Text(model.exercise.cue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if model.exercise.tracksWeight {
                    WeightControl(weight: $model.weight, unit: model.unit, suggested: model.suggestedWeight)
                }

                if model.target.seconds == nil && model.exercise.unitLabel == nil {
                    Stepper(value: $model.reps, in: 0...50) {
                        Text("\(model.reps) reps")
                            .monospacedDigit()
                    }
                }

                Button {
                    model.completeSet()
                } label: {
                    Label(model.isLastSetOfWorkout ? "Finish" : "Done", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .tint(.green)

                HStack {
                    HeartRateLabel(heartRate: heartRate)
                    Spacer()
                    Button("Skip") { model.skipExercise() }
                        .buttonStyle(.plain)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// Weight in big digits. Tap it, then turn the Digital Crown, or use − and +.
private struct WeightControl: View {
    @Binding var weight: Double
    let unit: WeightUnit
    let suggested: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Button { weight = max(0, weight - unit.increment) } label: { Image(systemName: "minus") }
                    .frame(width: 36)
                Text("\(weight, specifier: "%g") \(unit.symbol)")
                    .font(.title3.monospacedDigit())
                    .frame(maxWidth: .infinity)
                    .focusable()
                    .digitalCrownRotation($weight, from: 0, through: 600, by: unit.increment,
                                          sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
                Button { weight += unit.increment } label: { Image(systemName: "plus") }
                    .frame(width: 36)
            }
            if let suggested {
                Text("Suggested \(suggested, specifier: "%g") \(unit.symbol), from last time")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("First time: pick a weight you can do with good form")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct RestView: View {
    let until: Date
    let upNext: String
    let heartRate: Double
    let onSkip: () -> Void

    var body: some View {
        let now = Date()
        VStack(spacing: 6) {
            Text("Rest")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(timerInterval: now...max(until, now), countsDown: true)
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .multilineTextAlignment(.center)
            Text("Next: \(upNext)")
                .font(.caption2)
                .multilineTextAlignment(.center)
            HeartRateLabel(heartRate: heartRate)
            Button("Skip rest", action: onSkip)
        }
    }
}

private struct HeartRateLabel: View {
    let heartRate: Double

    var body: some View {
        Label(heartRate > 0 ? "\(Int(heartRate))" : "--", systemImage: "heart.fill")
            .font(.caption2.monospacedDigit())
            .foregroundStyle(.red)
    }
}

struct SummaryView: View {
    let session: LoggedSession
    let day: WorkoutDay
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nice work 💪")
                    .font(.headline)
                Text(day.displayName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("\(session.sets.count) sets · \(Int(session.duration / 60)) min")
                if let calories = session.activeCalories {
                    Text("\(Int(calories)) kcal")
                }
                if let heartRate = session.averageHeartRate {
                    Text("Avg \(Int(heartRate)) bpm")
                }
                Text(session.sets.isEmpty ? "Nothing logged, so nothing was saved." : "Saved. It'll show up on your iPhone.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Button("Done", action: onDone)
                    .tint(.green)
            }
        }
    }
}
