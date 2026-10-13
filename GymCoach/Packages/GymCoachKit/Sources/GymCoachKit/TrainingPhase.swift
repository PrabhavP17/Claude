import Foundation

/// Sets and a rep range for exercises that follow the current phase.
public struct RepScheme: Hashable, Sendable {
    public let sets: Int
    public let repLow: Int
    public let repHigh: Int
}

/// The four blocks of the 9-week plan.
public enum TrainingPhase: String, Codable, CaseIterable, Sendable {
    case foundation
    case strength
    case deload
    case power

    public var title: String {
        switch self {
        case .foundation: return "Foundation"
        case .strength: return "Strength"
        case .deload: return "Deload"
        case .power: return "Power"
        }
    }

    public var summary: String {
        switch self {
        case .foundation: return "Moderate weight. Finish each set with about 3 reps left in the tank."
        case .strength: return "Heavier. Finish each set with about 2 reps left in the tank."
        case .deload: return "Half the sets, same weight. Let your body recover."
        case .power: return "Heavy and explosive. Move the weight fast."
        }
    }

    public var scheme: RepScheme {
        switch self {
        case .foundation: return RepScheme(sets: 3, repLow: 10, repHigh: 12)
        case .strength: return RepScheme(sets: 4, repLow: 6, repHigh: 8)
        case .deload: return RepScheme(sets: 2, repLow: 6, repHigh: 8)
        case .power: return RepScheme(sets: 4, repLow: 4, repHigh: 6)
        }
    }

    /// Rest between sets for main lifts.
    public var restSeconds: Int {
        switch self {
        case .foundation, .deload: return 90
        case .strength, .power: return 120
        }
    }
}
