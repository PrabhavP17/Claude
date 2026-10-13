import Foundation

public enum WeightUnit: String, Codable, CaseIterable, Sendable {
    case lb
    case kg

    /// The smallest jump most gyms can load.
    public var increment: Double { self == .kg ? 2.5 : 5 }
    public var symbol: String { rawValue }
}

public struct LoggedSet: Codable, Hashable, Sendable {
    public var exerciseID: String
    public var setNumber: Int
    public var reps: Int
    public var weight: Double?
    public var seconds: Int?
    public var completedAt: Date

    public init(exerciseID: String, setNumber: Int, reps: Int, weight: Double? = nil,
                seconds: Int? = nil, completedAt: Date = Date()) {
        self.exerciseID = exerciseID
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.seconds = seconds
        self.completedAt = completedAt
    }
}

/// One finished workout. This is what the watch sends to the iPhone.
public struct LoggedSession: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var dayID: String
    public var phase: TrainingPhase
    public var unit: WeightUnit
    public var startedAt: Date
    public var endedAt: Date
    public var sets: [LoggedSet]
    public var averageHeartRate: Double?
    public var activeCalories: Double?

    public init(id: UUID = UUID(), dayID: String, phase: TrainingPhase, unit: WeightUnit,
                startedAt: Date, endedAt: Date, sets: [LoggedSet],
                averageHeartRate: Double? = nil, activeCalories: Double? = nil) {
        self.id = id
        self.dayID = dayID
        self.phase = phase
        self.unit = unit
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.sets = sets
        self.averageHeartRate = averageHeartRate
        self.activeCalories = activeCalories
    }

    public var duration: TimeInterval { endedAt.timeIntervalSince(startedAt) }

    public func sets(for exerciseID: String) -> [LoggedSet] {
        sets.filter { $0.exerciseID == exerciseID }
    }

    /// Heaviest weight used for an exercise in this session.
    public func topWeight(for exerciseID: String) -> Double? {
        sets(for: exerciseID).compactMap(\.weight).filter { $0 > 0 }.max()
    }
}
