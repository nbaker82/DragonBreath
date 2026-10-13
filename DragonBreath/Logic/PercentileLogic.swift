import Foundation

// MARK: - Protocol

/// Describes the score fields PercentileLogic needs from a workout result.
protocol WorkoutResultScoring {
    var timeSeconds: Int? { get }
    var rounds: Int? { get }
    var repsRemainder: Int? { get }
    var weight: Double? { get }
    var totalReps: Int? { get }
}

// MARK: - Pure Logic

enum PercentileLogic {

    /// Returns a 0.0–1.0 percentile for `result` compared against `allResults`.
    /// Higher value = better performance.
    static func percentile<R: WorkoutResultScoring>(
        for result: R,
        in allResults: [R],
        workoutType: WorkoutType
    ) -> Double {
        guard allResults.count > 1 else { return 1.0 }

        switch workoutType {
        case .forTime, .rft, .chipper:
            // Lower time = better → count results with time >= ours
            guard let t = result.timeSeconds else { return 0 }
            let betterOrEqual = allResults.filter { ($0.timeSeconds ?? Int.max) >= t }.count
            return Double(betterOrEqual) / Double(allResults.count)

        case .amrap, .emom, .deathBy:
            // Higher rounds+reps = better
            let score = roundsScore(result)
            let betterOrEqual = allResults.filter { roundsScore($0) <= score }.count
            return Double(betterOrEqual) / Double(allResults.count)

        case .maxLoad, .strength, .complex:
            // Higher weight = better
            guard let w = result.weight else { return 0 }
            let betterOrEqual = allResults.filter { ($0.weight ?? 0) <= w }.count
            return Double(betterOrEqual) / Double(allResults.count)

        case .tabata:
            guard let reps = result.totalReps else { return 0 }
            let betterOrEqual = allResults.filter { ($0.totalReps ?? 0) <= reps }.count
            return Double(betterOrEqual) / Double(allResults.count)

        default:
            return 0
        }
    }

    /// Returns the index of the personal-best result for a given workout type.
    static func personalBestIndex<R: WorkoutResultScoring>(
        in results: [R],
        workoutType: WorkoutType
    ) -> Int? {
        guard !results.isEmpty else { return nil }

        switch workoutType {
        case .forTime, .rft, .chipper:
            return results.indices
                .filter { results[$0].timeSeconds != nil }
                .min { (results[$0].timeSeconds ?? Int.max) < (results[$1].timeSeconds ?? Int.max) }

        case .amrap, .emom, .deathBy:
            return results.indices
                .filter { results[$0].rounds != nil }
                .max { roundsScore(results[$0]) < roundsScore(results[$1]) }

        case .maxLoad, .strength, .complex:
            return results.indices
                .filter { results[$0].weight != nil }
                .max { (results[$0].weight ?? 0) < (results[$1].weight ?? 0) }

        case .tabata:
            return results.indices
                .filter { results[$0].totalReps != nil }
                .max { (results[$0].totalReps ?? 0) < (results[$1].totalReps ?? 0) }

        default:
            return results.isEmpty ? nil : 0
        }
    }

    /// Human-readable label for a percentile value.
    static func label(for percentile: Double) -> String {
        if percentile >= 1.0 { return "🏆 PR" }
        if percentile >= 0.9 { return "Top 10%" }
        if percentile >= 0.75 { return "Top 25%" }
        if percentile >= 0.5 { return "Top 50%" }
        return "Bottom 50%"
    }

    // MARK: - Helpers

    private static func roundsScore<R: WorkoutResultScoring>(_ r: R) -> Int {
        (r.rounds ?? 0) * 1_000 + (r.repsRemainder ?? 0)
    }
}
