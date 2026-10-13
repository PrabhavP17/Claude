import Foundation
import Observation
import WatchKit
import GymCoachKit

/// Steps through a workout set by set, runs the rest timer, and logs what you did.
@MainActor
@Observable
final class WorkoutModel {
    enum Stage: Equatable {
        case active
        case resting(until: Date)
        case finished
    }

    let day: WorkoutDay
    let phase: TrainingPhase
    let unit: WeightUnit
    let startedAt = Date()

    private(set) var exerciseIndex = 0
    private(set) var setIndex = 0
    private(set) var stage: Stage = .active
    private(set) var logged: [LoggedSet] = []
    private(set) var suggestedWeight: Double?
    var weight: Double = 0
    var reps: Int = 0

    @ObservationIgnored private var history: (String) -> [LoggedSet] = { _ in [] }
    @ObservationIgnored private var restTask: Task<Void, Never>?

    init(day: WorkoutDay, phase: TrainingPhase, unit: WeightUnit) {
        self.day = day
        self.phase = phase
        self.unit = unit
    }

    var exercise: Exercise { day.exercises[exerciseIndex] }
    var target: SetTarget { exercise.target(in: phase) }
    var totalExercises: Int { day.exercises.count }

    var isLastSetOfWorkout: Bool {
        exerciseIndex == totalExercises - 1 && setIndex == target.sets - 1
    }

    /// Shown on the rest screen: what comes after the rest.
    var upNext: String {
        "\(exercise.name) · set \(setIndex + 1) of \(target.sets)"
    }

    /// Call once before the first set. `history` returns the sets from the last
    /// session that included an exercise, used to suggest a weight.
    func begin(history: @escaping (String) -> [LoggedSet]) {
        self.history = history
        prepareExercise()
    }

    func completeSet() {
        guard stage == .active else { return }
        let finishedTarget = target
        logged.append(LoggedSet(
            exerciseID: exercise.id,
            setNumber: setIndex + 1,
            reps: finishedTarget.seconds == nil ? reps : 1,
            weight: exercise.tracksWeight ? weight : nil,
            seconds: finishedTarget.seconds
        ))
        WKInterfaceDevice.current().play(.success)

        setIndex += 1
        if setIndex >= finishedTarget.sets {
            moveToNextExercise(restSeconds: finishedTarget.restSeconds)
        } else {
            startRest(seconds: finishedTarget.restSeconds)
        }
    }

    func skipExercise() {
        guard stage != .finished else { return }
        moveToNextExercise(restSeconds: nil)
    }

    func skipRest() {
        restTask?.cancel()
        if case .resting = stage { stage = .active }
    }

    func finish() {
        restTask?.cancel()
        stage = .finished
    }

    func makeSession(summary: HealthWorkoutManager.Summary) -> LoggedSession {
        LoggedSession(dayID: day.id, phase: phase, unit: unit, startedAt: startedAt, endedAt: Date(),
                      sets: logged, averageHeartRate: summary.averageHeartRate,
                      activeCalories: summary.activeCalories)
    }

    // MARK: Private

    private func moveToNextExercise(restSeconds: Int?) {
        restTask?.cancel()
        guard exerciseIndex + 1 < totalExercises else {
            finish()
            return
        }
        exerciseIndex += 1
        setIndex = 0
        prepareExercise()
        if let restSeconds {
            startRest(seconds: restSeconds)
        } else {
            stage = .active
        }
    }

    /// Sets up reps and the suggested weight for a new exercise. Within an
    /// exercise the weight stays where you left it.
    private func prepareExercise() {
        reps = target.repHigh
        guard exercise.tracksWeight else {
            suggestedWeight = nil
            return
        }
        suggestedWeight = Progression.suggestedWeight(previous: history(exercise.id), target: target,
                                                      phase: phase, unit: unit)
        weight = suggestedWeight ?? 0
    }

    private func startRest(seconds: Int) {
        restTask?.cancel()
        stage = .resting(until: Date().addingTimeInterval(TimeInterval(seconds)))
        restTask = Task { [weak self] in
            if seconds > 10 {
                try? await Task.sleep(for: .seconds(seconds - 10))
                guard !Task.isCancelled else { return }
                WKInterfaceDevice.current().play(.directionUp) // 10 seconds left
                try? await Task.sleep(for: .seconds(10))
            } else {
                try? await Task.sleep(for: .seconds(seconds))
            }
            guard !Task.isCancelled, let self else { return }
            WKInterfaceDevice.current().play(.notification) // time for the next set
            if case .resting = self.stage { self.stage = .active }
        }
    }
}
