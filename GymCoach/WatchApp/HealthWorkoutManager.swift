import Foundation
import HealthKit
import Observation

/// Runs an Apple Health workout while you train: live heart rate, calories, and
/// the workout saved to the Fitness app. It also keeps the app awake on your
/// wrist, so the rest timer keeps buzzing when your arm is down.
@MainActor
@Observable
final class HealthWorkoutManager: NSObject {
    struct Summary {
        var averageHeartRate: Double?
        var activeCalories: Double?
    }

    private(set) var heartRate: Double = 0
    private(set) var activeCalories: Double = 0

    @ObservationIgnored private let store = HKHealthStore()
    @ObservationIgnored private var session: HKWorkoutSession?
    @ObservationIgnored private var builder: HKLiveWorkoutBuilder?

    func start(activity: HKWorkoutActivityType) async {
        guard HKHealthStore.isHealthDataAvailable(), session == nil else { return }

        let share: Set<HKSampleType> = [HKObjectType.workoutType()]
        let read: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
        ]

        do {
            try await store.requestAuthorization(toShare: share, read: read)

            let configuration = HKWorkoutConfiguration()
            configuration.activityType = activity
            configuration.locationType = .indoor

            let session = try HKWorkoutSession(healthStore: store, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: configuration)
            builder.delegate = self
            self.session = session
            self.builder = builder

            let start = Date()
            session.startActivity(with: start)
            try await builder.beginCollection(at: start)
        } catch {
            // Health is optional. The workout still runs without heart rate.
            session = nil
            builder = nil
        }
    }

    func end() async -> Summary {
        guard let session, let builder else { return Summary() }
        session.end()

        var summary = Summary()
        do {
            try await builder.endCollection(at: Date())
            let bpm = HKUnit.count().unitDivided(by: .minute())
            summary.averageHeartRate = builder.statistics(for: HKQuantityType(.heartRate))?
                .averageQuantity()?.doubleValue(for: bpm)
            summary.activeCalories = builder.statistics(for: HKQuantityType(.activeEnergyBurned))?
                .sumQuantity()?.doubleValue(for: .kilocalorie())
            _ = try await builder.finishWorkout()
        } catch {}

        self.session = nil
        self.builder = nil
        return summary
    }
}

extension HealthWorkoutManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                                    didCollectDataOf collectedTypes: Set<HKSampleType>) {
        let bpm = HKUnit.count().unitDivided(by: .minute())
        let heartRate = workoutBuilder.statistics(for: HKQuantityType(.heartRate))?
            .mostRecentQuantity()?.doubleValue(for: bpm)
        let calories = workoutBuilder.statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?.doubleValue(for: .kilocalorie())

        Task { @MainActor in
            if let heartRate { self.heartRate = heartRate }
            if let calories { self.activeCalories = calories }
        }
    }
}
