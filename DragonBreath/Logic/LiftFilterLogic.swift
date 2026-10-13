import Foundation

// MARK: - Protocol

/// Describes the properties LiftFilterLogic needs from a lift log.
protocol LiftLoggable {
    var movementID: UUID? { get }
    var movementName: String? { get }
    var date: Date { get }
    var maxWeight: Double? { get }
}

// MARK: - Pure Logic

enum LiftFilterLogic {

    /// Filters and sorts lift logs by movement, search text, and date range.
    static func apply<L: LiftLoggable>(
        to logs: [L],
        movementID: UUID?,
        searchText: String,
        startDate: Date?,
        endDate: Date?
    ) -> [L] {
        var result = logs

        if let id = movementID {
            result = result.filter { $0.movementID == id }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.movementName?.localizedCaseInsensitiveContains(searchText) == true
            }
        }

        if let start = startDate {
            result = result.filter { $0.date >= start }
        }

        if let end = endDate {
            result = result.filter { $0.date <= end }
        }

        return result.sorted { $0.date > $1.date }
    }

    /// Returns the personal-best max weight for a movement across all logs.
    static func personalBest<L: LiftLoggable>(movementID: UUID, in logs: [L]) -> Double? {
        logs.filter { $0.movementID == movementID }
            .compactMap { $0.maxWeight }
            .max()
    }

    /// Human-readable percentile label for a given weight vs historical logs.
    static func percentileLabel<L: LiftLoggable>(weight: Double, movementID: UUID, logs: [L]) -> String {
        let allMaxes = logs
            .filter { $0.movementID == movementID }
            .compactMap { $0.maxWeight }

        guard allMaxes.count > 1 else { return "First Log!" }

        let rank = allMaxes.filter { $0 <= weight }.count
        let percentile = Double(rank) / Double(allMaxes.count)

        if percentile >= 1.0  { return "🏆 New PR!" }
        if percentile >= 0.9  { return "Top 10% of your lifts" }
        if percentile >= 0.75 { return "Top 25% of your lifts" }
        if percentile >= 0.5  { return "Above average" }
        return "Keep grinding 💪"
    }
}
