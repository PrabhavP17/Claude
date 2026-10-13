import Foundation

/// How an exercise decides its sets and reps.
public enum Prescription: Hashable, Sendable {
    /// Sets and reps come from the current phase (main lifts).
    case phase
    /// Same every phase, except deload halves the sets.
    case fixed(sets: Int, reps: Int)
    /// Held for a number of seconds, e.g. planks. Deload halves the sets.
    case timed(sets: Int, seconds: Int)
    /// Conditioning intervals with a different round count per phase.
    case rounds(foundation: Int, strength: Int, deload: Int, power: Int, workSeconds: Int, restSeconds: Int)
}

/// What to do for one exercise today.
public struct SetTarget: Hashable, Sendable {
    public let sets: Int
    public let repLow: Int
    public let repHigh: Int
    public let seconds: Int?
    public let restSeconds: Int

    public var repsLabel: String {
        if let seconds { return "\(seconds) s" }
        if repLow == repHigh { return "\(repLow) reps" }
        return "\(repLow)–\(repHigh) reps"
    }
}

public struct Exercise: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let cue: String
    public let prescription: Prescription
    public let perSide: Bool
    public let tracksWeight: Bool
    /// Replaces "reps" in the description for drills, e.g. "10 m sprint".
    public let unitLabel: String?

    public init(
        id: String,
        name: String,
        cue: String = "",
        prescription: Prescription,
        perSide: Bool = false,
        tracksWeight: Bool = false,
        unitLabel: String? = nil
    ) {
        self.id = id
        self.name = name
        self.cue = cue
        self.prescription = prescription
        self.perSide = perSide
        self.tracksWeight = tracksWeight
        self.unitLabel = unitLabel
    }

    public func target(in phase: TrainingPhase) -> SetTarget {
        func halvedOnDeload(_ sets: Int) -> Int {
            phase == .deload ? max(1, (sets + 1) / 2) : sets
        }

        switch prescription {
        case .phase:
            let scheme = phase.scheme
            return SetTarget(sets: scheme.sets, repLow: scheme.repLow, repHigh: scheme.repHigh,
                             seconds: nil, restSeconds: phase.restSeconds)
        case let .fixed(sets, reps):
            return SetTarget(sets: halvedOnDeload(sets), repLow: reps, repHigh: reps,
                             seconds: nil, restSeconds: 60)
        case let .timed(sets, seconds):
            return SetTarget(sets: halvedOnDeload(sets), repLow: 1, repHigh: 1,
                             seconds: seconds, restSeconds: 45)
        case let .rounds(foundation, strength, deload, power, workSeconds, restSeconds):
            let rounds: Int
            switch phase {
            case .foundation: rounds = foundation
            case .strength: rounds = strength
            case .deload: rounds = deload
            case .power: rounds = power
            }
            return SetTarget(sets: rounds, repLow: 1, repHigh: 1,
                             seconds: workSeconds, restSeconds: restSeconds)
        }
    }

    /// For example "4 × 6–8 reps" or "3 × 20 s each side".
    public func targetDescription(in phase: TrainingPhase) -> String {
        let target = target(in: phase)
        let what = unitLabel ?? target.repsLabel
        return "\(target.sets) × \(what)" + (perSide ? " each side" : "")
    }
}

public struct WorkoutDay: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let usualDay: String
    public let focus: String
    public let isConditioning: Bool
    public let warmup: [String]
    public let exercises: [Exercise]
    public let cooldown: [String]

    public init(id: String, title: String, usualDay: String, focus: String, isConditioning: Bool = false,
                warmup: [String], exercises: [Exercise], cooldown: [String]) {
        self.id = id
        self.title = title
        self.usualDay = usualDay
        self.focus = focus
        self.isConditioning = isConditioning
        self.warmup = warmup
        self.exercises = exercises
        self.cooldown = cooldown
    }

    public var displayName: String { "Day \(id): \(title)" }
}
