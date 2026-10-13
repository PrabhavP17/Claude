import Foundation

/// Progressive overload: suggests today's weight from last time.
public enum Progression {
    /// - Returns: nil when there is no previous weight to go on.
    ///
    /// Rules:
    /// - Deload week: same weight as last time.
    /// - Every set at last time's top weight reached the top of today's rep range: add one increment.
    /// - Otherwise: stay at last time's top weight until you own it.
    public static func suggestedWeight(previous: [LoggedSet], target: SetTarget,
                                       phase: TrainingPhase, unit: WeightUnit) -> Double? {
        let weighted = previous.filter { ($0.weight ?? 0) > 0 }
        guard let top = weighted.compactMap(\.weight).max() else { return nil }
        if phase == .deload { return top }

        let setsAtTop = weighted.filter { $0.weight == top }
        let ownedIt = setsAtTop.allSatisfy { $0.reps >= target.repHigh }
        return ownedIt ? top + unit.increment : top
    }
}
