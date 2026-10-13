import SwiftUI
import UniformTypeIdentifiers

// MARK: - btwb Import ViewModel

@Observable
final class BTWBImportViewModel {
    var isImporting: Bool = false
    var importResult: ImportResult? = nil
    var showFilePicker: Bool = false
    var isProcessing: Bool = false

    struct ImportResult {
        var workoutsImported: Int
        var liftsImported: Int
        var errors: [String]
        var success: Bool
    }

    func importCSV(url: URL, workoutRepo: WorkoutRepository, liftRepo: LiftRepository) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            let data = try Data(contentsOf: url)
            guard let content = String(data: data, encoding: .utf8) else {
                importResult = ImportResult(workoutsImported: 0, liftsImported: 0,
                                           errors: ["Could not read file encoding."], success: false)
                return
            }

            let result = await BTWBImportService.parse(csv: content, workoutRepo: workoutRepo, liftRepo: liftRepo)
            importResult = result
        } catch {
            importResult = ImportResult(workoutsImported: 0, liftsImported: 0,
                                        errors: [error.localizedDescription], success: false)
        }
    }
}

// MARK: - btwb CSV Parser

struct BTWBImportService {

    /// btwb exports two types of CSVs:
    /// 1. workout_results.csv — workout logs
    /// 2. lift_results.csv — lift/strength logs
    /// We detect which type we have based on headers.

    static func parse(csv: String, workoutRepo: WorkoutRepository, liftRepo: LiftRepository) async -> BTWBImportViewModel.ImportResult {
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard let header = lines.first else {
            return .init(workoutsImported: 0, liftsImported: 0, errors: ["Empty file"], success: false)
        }

        let headers = header.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }

        if headers.contains("workout") || headers.contains("score") {
            return parseWorkoutResults(lines: Array(lines.dropFirst()), headers: headers, workoutRepo: workoutRepo)
        } else if headers.contains("movement") || headers.contains("lift") {
            return parseLiftResults(lines: Array(lines.dropFirst()), headers: headers, liftRepo: liftRepo)
        } else {
            return .init(workoutsImported: 0, liftsImported: 0,
                        errors: ["Unrecognized CSV format. Expected btwb workout or lift export."],
                        success: false)
        }
    }

    private static func parseWorkoutResults(lines: [String], headers: [String], workoutRepo: WorkoutRepository) -> BTWBImportViewModel.ImportResult {
        var imported = 0
        let errors: [String] = []

        let existingWorkouts = workoutRepo.allWorkouts()
        var workoutMap: [String: Workout] = Dictionary(uniqueKeysWithValues: existingWorkouts.map { ($0.name.lowercased(), $0) })

        let workoutIdx  = headers.firstIndex(of: "workout") ?? headers.firstIndex(of: "workout name") ?? -1
        let scoreIdx    = headers.firstIndex(of: "score") ?? headers.firstIndex(of: "result") ?? -1
        let dateIdx     = headers.firstIndex(of: "date") ?? -1
        let notesIdx    = headers.firstIndex(of: "notes") ?? -1
        let rxIdx       = headers.firstIndex(of: "rx") ?? -1

        guard workoutIdx >= 0 else {
            return .init(workoutsImported: 0, liftsImported: 0,
                        errors: ["Could not find 'workout' column."], success: false)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        for (_, line) in lines.enumerated() {
            let cols = parseCSVLine(line)
            guard cols.count > workoutIdx else { continue }

            let workoutName = cols[workoutIdx].trimmingCharacters(in: .whitespaces)
            guard !workoutName.isEmpty else { continue }

            // Get or create workout
            let key = workoutName.lowercased()
            let workout: Workout
            if let existing = workoutMap[key] {
                workout = existing
            } else {
                let newWorkout = Workout(
                    name: workoutName,
                    workoutType: .custom,
                    workoutDescription: "Imported from btwb",
                    isBenchmark: false
                )
                workoutRepo.insert(newWorkout)
                workoutMap[key] = newWorkout
                workout = newWorkout
            }

            // Parse score
            let scoreStr = scoreIdx >= 0 && cols.count > scoreIdx ? cols[scoreIdx] : ""
            let (scoreType, timeSeconds, rounds, repsRemainder, weight) = parseScore(scoreStr)

            // Parse date
            let dateStr = dateIdx >= 0 && cols.count > dateIdx ? cols[dateIdx] : ""
            let date = formatter.date(from: dateStr) ?? Date()

            let notes = notesIdx >= 0 && cols.count > notesIdx ? cols[notesIdx] : ""
            let rxStr = rxIdx >= 0 && cols.count > rxIdx ? cols[rxIdx].lowercased() : "true"
            let rx = rxStr == "true" || rxStr == "yes" || rxStr == "1" || rxStr == "rx"

            let result = WorkoutResult(
                workout: workout,
                date: date,
                scoreType: scoreType,
                timeSeconds: timeSeconds,
                rounds: rounds,
                repsRemainder: repsRemainder,
                weight: weight,
                notes: notes,
                rx: rx
            )
            workoutRepo.insertResult(result)
            imported += 1
        }

        workoutRepo.commit()
        return .init(workoutsImported: imported, liftsImported: 0, errors: errors, success: true)
    }

    private static func parseLiftResults(lines: [String], headers: [String], liftRepo: LiftRepository) -> BTWBImportViewModel.ImportResult {
        var imported = 0
        var errors: [String] = []

        let existingMovements = liftRepo.allMovements()
        var movementMap: [String: Movement] = Dictionary(uniqueKeysWithValues: existingMovements.map { ($0.name.lowercased(), $0) })

        let movIdx   = headers.firstIndex(of: "movement") ?? headers.firstIndex(of: "lift") ?? -1
        let weightIdx = headers.firstIndex(of: "weight") ?? headers.firstIndex(of: "load") ?? -1
        let repsIdx   = headers.firstIndex(of: "reps") ?? -1
        let dateIdx   = headers.firstIndex(of: "date") ?? -1
        let notesIdx  = headers.firstIndex(of: "notes") ?? -1

        guard movIdx >= 0 else {
            return .init(workoutsImported: 0, liftsImported: 0,
                        errors: ["Could not find 'movement' column."], success: false)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        for line in lines {
            let cols = parseCSVLine(line)
            guard cols.count > movIdx else { continue }

            let movName = cols[movIdx].trimmingCharacters(in: .whitespaces)
            guard !movName.isEmpty else { continue }

            let key = movName.lowercased()
            let movement: Movement
            if let existing = movementMap[key] {
                movement = existing
            } else {
                let newMov = Movement(name: movName, category: .weightlifting)
                liftRepo.insertMovement(newMov)
                movementMap[key] = newMov
                movement = newMov
            }

            let weightStr = weightIdx >= 0 && cols.count > weightIdx ? cols[weightIdx] : ""
            let weight = Double(weightStr.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression))

            let reps = repsIdx >= 0 && cols.count > repsIdx ? Int(cols[repsIdx]) : nil
            let dateStr = dateIdx >= 0 && cols.count > dateIdx ? cols[dateIdx] : ""
            let date = formatter.date(from: dateStr) ?? Date()
            let notes = notesIdx >= 0 && cols.count > notesIdx ? cols[notesIdx] : ""

            let liftSet = LiftSet(setNumber: 1, reps: reps, weight: weight)
            let log = LiftLog(movement: movement, date: date, sets: [liftSet], notes: notes)
            liftRepo.insertLog(log)
            imported += 1
        }

        liftRepo.commit()
        return .init(workoutsImported: 0, liftsImported: imported, errors: errors, success: true)
    }

    // MARK: - Score Parser

    private static func parseScore(_ score: String) -> (ScoreType, Int?, Int?, Int?, Double?) {
        let s = score.trimmingCharacters(in: .whitespaces)

        // Time: "12:34" or "1:23:45"
        let timeParts = s.components(separatedBy: ":")
        if timeParts.count == 2, let m = Int(timeParts[0]), let sec = Int(timeParts[1]) {
            return (.time, m * 60 + sec, nil, nil, nil)
        }
        if timeParts.count == 3, let h = Int(timeParts[0]), let m = Int(timeParts[1]), let sec = Int(timeParts[2]) {
            return (.time, h * 3600 + m * 60 + sec, nil, nil, nil)
        }

        // Rounds + reps: "12+5" or "12 rounds + 5 reps"
        if s.contains("+") {
            let parts = s.components(separatedBy: "+")
            let r = Int(parts[0].components(separatedBy: .whitespaces).first ?? "")
            let reps = Int(parts[1].components(separatedBy: .whitespaces).first ?? "")
            if let r = r { return (.rounds, nil, r, reps, nil) }
        }

        // Weight: "225 lbs" or "102.5 kg"
        if s.lowercased().contains("lb") || s.lowercased().contains("kg") {
            let num = Double(s.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression))
            return (.weight, nil, nil, nil, num)
        }

        // Pure number — could be reps
        if let num = Int(s) {
            return (.reps, nil, num, nil, nil)
        }

        return (.time, nil, nil, nil, nil)
    }

    // MARK: - CSV Line Parser (handles quoted fields)

    private static func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false

        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }
        result.append(current)
        return result
    }
}
