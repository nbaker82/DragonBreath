import SwiftUI
import SwiftData

// MARK: - CSV Parser

/// Main-actor isolated because the repositories wrap the container's `mainContext`.
@MainActor
struct CSVImportService {

    /// Two kinds of CSV are supported:
    /// 1. workout_results.csv — workout logs
    /// 2. lift_results.csv — lift/strength logs
    /// We detect which type we have based on headers.

    static func parse(csv: String, workoutRepo: WorkoutRepository, liftRepo: LiftRepository) -> ImportViewModel.ImportResult {
        // Parse the whole file at once so quoted fields may contain commas and line breaks.
        let rows = parseCSV(csv)
        guard let header = rows.first else {
            return .init(workoutsImported: 0, liftsImported: 0, errors: ["Empty file"], success: false)
        }

        // Strip whitespace and a UTF-8 byte-order mark, which spreadsheet exports often prepend.
        let trimSet = CharacterSet.whitespaces.union(CharacterSet(charactersIn: "\u{FEFF}"))
        let headers = header.map { $0.trimmingCharacters(in: trimSet).lowercased() }
        let dataRows = Array(rows.dropFirst())

        if headers.contains("workout") || headers.contains("workout name") || headers.contains("score") {
            return parseWorkoutResults(rows: dataRows, headers: headers, workoutRepo: workoutRepo)
        } else if headers.contains("movement") || headers.contains("lift") {
            return parseLiftResults(rows: dataRows, headers: headers, liftRepo: liftRepo)
        } else {
            return .init(workoutsImported: 0, liftsImported: 0,
                        errors: ["Unrecognized CSV format. Expected a workout or lift export."],
                        success: false)
        }
    }

    private static func parseWorkoutResults(rows: [[String]], headers: [String], workoutRepo: WorkoutRepository) -> ImportViewModel.ImportResult {
        var imported = 0
        var duplicates = 0
        var errors = ErrorCollector()

        let existingWorkouts = workoutRepo.allWorkouts()
        // Names aren't unique (case variants, repeated Quick Log auto-names), so keep the first match.
        var workoutMap: [String: Workout] = Dictionary(
            existingWorkouts.map { ($0.name.lowercased(), $0) },
            uniquingKeysWith: { first, _ in first }
        )
        // Fingerprints of results already in the store, so re-importing a file doesn't duplicate them.
        let existingKeys = Set(existingWorkouts.flatMap { workout in
            workout.results.map { workoutKey(name: workout.name, result: $0) }
        })

        let workoutIdx  = headers.firstIndex(of: "workout") ?? headers.firstIndex(of: "workout name")
        let scoreIdx    = headers.firstIndex(of: "score") ?? headers.firstIndex(of: "result")
        let dateIdx     = headers.firstIndex(of: "date")
        let notesIdx    = headers.firstIndex(of: "notes")
        let rxIdx       = headers.firstIndex(of: "rx")

        guard let workoutIdx else {
            return .init(workoutsImported: 0, liftsImported: 0,
                        errors: ["Could not find 'workout' column."], success: false)
        }

        for (offset, cols) in rows.enumerated() {
            let rowNumber = offset + 2  // 1-based, after the header row

            let workoutName = field(cols, workoutIdx)
            guard !workoutName.isEmpty else {
                errors.add("Row \(rowNumber): missing workout name — skipped.")
                continue
            }

            guard let date = parseDate(field(cols, dateIdx)) else {
                errors.add("Row \(rowNumber) (\(workoutName)): missing or unreadable date — skipped.")
                continue
            }

            let scoreStr = field(cols, scoreIdx)
            let score = parseScore(scoreStr)

            var notes = field(cols, notesIdx)
            if !score.recognized && !scoreStr.isEmpty {
                // Keep scores we can't interpret (e.g. "Completed", "5 x 3") rather than dropping them.
                notes = notes.isEmpty ? scoreStr : "\(scoreStr) — \(notes)"
            }

            let rxStr = rxIdx == nil ? "true" : field(cols, rxIdx).lowercased()
            let rx = rxStr == "true" || rxStr == "yes" || rxStr == "1" || rxStr == "rx"

            let key = workoutKey(name: workoutName, date: date, score: score)
            if existingKeys.contains(key) {
                duplicates += 1
                continue
            }

            // Get or create workout
            let mapKey = workoutName.lowercased()
            let workout: Workout
            if let existing = workoutMap[mapKey] {
                workout = existing
            } else {
                let newWorkout = Workout(
                    name: workoutName,
                    workoutType: .custom,
                    workoutDescription: "Imported from CSV",
                    isBenchmark: false
                )
                workoutRepo.insert(newWorkout)
                workoutMap[mapKey] = newWorkout
                workout = newWorkout
            }

            let result = WorkoutResult(
                workout: workout,
                date: date,
                scoreType: score.type,
                timeSeconds: score.timeSeconds,
                rounds: score.rounds,
                repsRemainder: score.repsRemainder,
                weight: score.weight,
                totalReps: score.totalReps,
                notes: notes,
                rx: rx
            )
            workoutRepo.insertResult(result)
            imported += 1
        }

        workoutRepo.commit()
        return .init(workoutsImported: imported, liftsImported: 0, errors: errors.messages,
                     success: true, duplicatesSkipped: duplicates)
    }

    private static func parseLiftResults(rows: [[String]], headers: [String], liftRepo: LiftRepository) -> ImportViewModel.ImportResult {
        var imported = 0
        var duplicates = 0
        var errors = ErrorCollector()

        let existingMovements = liftRepo.allMovements()
        // Names aren't guaranteed unique once case is ignored, so keep the first match.
        var movementMap: [String: Movement] = Dictionary(
            existingMovements.map { ($0.name.lowercased(), $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let existingKeys = Set(existingMovements.flatMap { movement in
            movement.liftLogs.map { log in
                liftKey(movement: movement.name, date: log.date,
                        weight: log.sets.first?.weight, reps: log.sets.first?.reps, unit: log.unit)
            }
        })

        let movIdx    = headers.firstIndex(of: "movement") ?? headers.firstIndex(of: "lift")
        let weightIdx = headers.firstIndex(of: "weight") ?? headers.firstIndex(of: "load")
        let repsIdx   = headers.firstIndex(of: "reps")
        let dateIdx   = headers.firstIndex(of: "date")
        let notesIdx  = headers.firstIndex(of: "notes")

        guard let movIdx else {
            return .init(workoutsImported: 0, liftsImported: 0,
                        errors: ["Could not find 'movement' column."], success: false)
        }

        for (offset, cols) in rows.enumerated() {
            let rowNumber = offset + 2

            let movName = field(cols, movIdx)
            guard !movName.isEmpty else {
                errors.add("Row \(rowNumber): missing movement name — skipped.")
                continue
            }

            guard let date = parseDate(field(cols, dateIdx)) else {
                errors.add("Row \(rowNumber) (\(movName)): missing or unreadable date — skipped.")
                continue
            }

            let weightStr = field(cols, weightIdx)
            let weight = parseNumber(weightStr)
            // Loads may be written "100 kg"; anything else is treated as pounds.
            let unit: WeightUnit = weightStr.lowercased().contains("kg") ? .kg : .lbs
            let reps = Int(field(cols, repsIdx))
            let notes = field(cols, notesIdx)

            if existingKeys.contains(liftKey(movement: movName, date: date, weight: weight, reps: reps, unit: unit)) {
                duplicates += 1
                continue
            }

            let mapKey = movName.lowercased()
            let movement: Movement
            if let existing = movementMap[mapKey] {
                movement = existing
            } else {
                let newMov = Movement(name: movName, category: .weightlifting)
                liftRepo.insertMovement(newMov)
                movementMap[mapKey] = newMov
                movement = newMov
            }

            let liftSet = LiftSet(setNumber: 1, reps: reps, weight: weight)
            let log = LiftLog(movement: movement, date: date, sets: [liftSet], notes: notes, unit: unit)
            liftRepo.insertLog(log)
            imported += 1
        }

        liftRepo.commit()
        return .init(workoutsImported: 0, liftsImported: imported, errors: errors.messages,
                     success: true, duplicatesSkipped: duplicates)
    }

    // MARK: - Field helpers

    /// Trimmed value of column `index`, or "" when the column is absent or the row is short.
    private static func field(_ cols: [String], _ index: Int?) -> String {
        guard let index, cols.indices.contains(index) else { return "" }
        return cols[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func parseNumber(_ text: String) -> Double? {
        Double(text.replacing(/[^0-9.]/, with: ""))
    }

    /// Exports commonly use either US or ISO date formats.
    private static let dateFormatters: [DateFormatter] = ["MM/dd/yyyy", "yyyy-MM-dd", "MM/dd/yy"].map { format in
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter
    }

    private static func parseDate(_ text: String) -> Date? {
        guard !text.isEmpty else { return nil }
        for formatter in dateFormatters {
            if let date = formatter.date(from: text) { return date }
        }
        return nil
    }

    // MARK: - Duplicate detection

    private static func workoutKey(name: String, date: Date, score: ParsedScore) -> String {
        workoutKey(name: name, date: date, timeSeconds: score.timeSeconds, rounds: score.rounds,
                   repsRemainder: score.repsRemainder, weight: score.weight, totalReps: score.totalReps)
    }

    private static func workoutKey(name: String, result: WorkoutResult) -> String {
        workoutKey(name: name, date: result.date, timeSeconds: result.timeSeconds, rounds: result.rounds,
                   repsRemainder: result.repsRemainder, weight: result.weight, totalReps: result.totalReps)
    }

    private static func workoutKey(
        name: String, date: Date, timeSeconds: Int?, rounds: Int?,
        repsRemainder: Int?, weight: Double?, totalReps: Int?
    ) -> String {
        let day = Calendar.current.startOfDay(for: date).timeIntervalSince1970
        let parts: [String] = [
            name.lowercased(), "\(day)",
            timeSeconds.map(String.init) ?? "", rounds.map(String.init) ?? "",
            repsRemainder.map(String.init) ?? "", weight.map { "\($0)" } ?? "",
            totalReps.map(String.init) ?? ""
        ]
        return parts.joined(separator: "|")
    }

    private static func liftKey(movement: String, date: Date, weight: Double?, reps: Int?, unit: WeightUnit) -> String {
        let day = Calendar.current.startOfDay(for: date).timeIntervalSince1970
        return [movement.lowercased(), "\(day)", weight.map { "\($0)" } ?? "",
                reps.map(String.init) ?? "", unit.rawValue].joined(separator: "|")
    }

    // MARK: - Score Parser

    struct ParsedScore {
        var type: ScoreType
        var timeSeconds: Int? = nil
        var rounds: Int? = nil
        var repsRemainder: Int? = nil
        var weight: Double? = nil
        var totalReps: Int? = nil
        /// False when the text didn't match a known format; the caller keeps the raw text.
        var recognized = true
    }

    static func parseScore(_ score: String) -> ParsedScore {
        let s = score.trimmingCharacters(in: .whitespaces)

        // Time: "12:34" or "1:23:45"
        let timeParts = s.components(separatedBy: ":").map { $0.trimmingCharacters(in: .whitespaces) }
        if timeParts.count == 2, let m = Int(timeParts[0]), let sec = Int(timeParts[1]) {
            return ParsedScore(type: .time, timeSeconds: m * 60 + sec)
        }
        if timeParts.count == 3, let h = Int(timeParts[0]), let m = Int(timeParts[1]), let sec = Int(timeParts[2]) {
            return ParsedScore(type: .time, timeSeconds: h * 3600 + m * 60 + sec)
        }

        // Rounds + reps: "12+5" or "12 rounds + 5 reps"
        let plusParts = s.components(separatedBy: "+").map { $0.trimmingCharacters(in: .whitespaces) }
        if plusParts.count == 2,
           let r = Int(plusParts[0].components(separatedBy: .whitespaces).first ?? "") {
            let reps = Int(plusParts[1].components(separatedBy: .whitespaces).first ?? "")
            return ParsedScore(type: .rounds, rounds: r, repsRemainder: reps)
        }

        // Weight: "225 lbs" or "102.5 kg"
        if s.lowercased().contains("lb") || s.lowercased().contains("kg") {
            return ParsedScore(type: .weight, weight: parseNumber(s))
        }

        // Pure number — could be reps
        if let num = Int(s) {
            return ParsedScore(type: .reps, totalReps: num)
        }

        // Unknown: store as a free-form score so `displayScore` falls back to notes.
        return ParsedScore(type: .reps, recognized: false)
    }

    // MARK: - CSV Parser (RFC 4180: quoted fields, "" escapes, embedded newlines)

    static func parseCSV(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var inQuotes = false
        let chars = Array(text)
        var i = 0

        while i < chars.count {
            let char = chars[i]
            if inQuotes {
                if char == "\"" {
                    if i + 1 < chars.count, chars[i + 1] == "\"" {
                        field.append("\"")  // escaped quote
                        i += 1
                    } else {
                        inQuotes = false
                    }
                } else {
                    field.append(char)
                }
            } else if char == "\"" {
                inQuotes = true
            } else if char == "," {
                row.append(field)
                field = ""
            } else if char.isNewline {  // "\r\n" is a single Character in Swift
                row.append(field)
                rows.append(row)
                row = []
                field = ""
            } else {
                field.append(char)
            }
            i += 1
        }
        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }

        // Drop blank lines.
        return rows.filter { !$0.allSatisfy { $0.trimmingCharacters(in: .whitespaces).isEmpty } }
    }
}
