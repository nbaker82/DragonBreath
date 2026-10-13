import SwiftData
import Foundation

// MARK: - Movement

@Model
final class Movement {
    var id: UUID
    var name: String
    var category: MovementCategory
    var scoreTypes: [ScoreType]

    @Relationship(deleteRule: .nullify, inverse: \Workout.movements)
    var workouts: [Workout] = []

    @Relationship(deleteRule: .cascade, inverse: \LiftLog.movement)
    var liftLogs: [LiftLog] = []

    init(name: String, category: MovementCategory, scoreTypes: [ScoreType] = [.weight]) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.scoreTypes = scoreTypes
    }
}

enum MovementCategory: String, Codable, CaseIterable {
    case weightlifting  = "Weightlifting"
    case gymnastics     = "Gymnastics"
    case monostructural = "Monostructural"
    case strongman      = "Strongman"
}

enum ScoreType: String, Codable, CaseIterable {
    case weight   = "Weight (lbs/kg)"
    case reps     = "Reps"
    case time     = "Time"
    case distance = "Distance"
    case height   = "Height"
    case rounds   = "Rounds + Reps"
}

// MARK: - Workout

@Model
final class Workout {
    var id: UUID
    var name: String
    var workoutType: WorkoutType
    var workoutDescription: String
    var timeCap: Int?           // seconds, nil = no cap
    var isBenchmark: Bool       // named benchmark Girls (Fran, Helen, etc.)
    var isHero: Bool            // Hero WODs (Murph, Chad, etc.)
    var isOpen: Bool            // CrossFit Open workouts
    var createdAt: Date
    var movements: [Movement]

    @Relationship(deleteRule: .cascade, inverse: \WorkoutResult.workout)
    var results: [WorkoutResult] = []

    init(
        name: String,
        workoutType: WorkoutType,
        workoutDescription: String,
        timeCap: Int? = nil,
        isBenchmark: Bool = false,
        isHero: Bool = false,
        isOpen: Bool = false,
        movements: [Movement] = []
    ) {
        self.id = UUID()
        self.name = name
        self.workoutType = workoutType
        self.workoutDescription = workoutDescription
        self.timeCap = timeCap
        self.isBenchmark = isBenchmark
        self.isHero = isHero
        self.isOpen = isOpen
        self.createdAt = Date()
        self.movements = movements
    }
}

enum WorkoutType: String, Codable, CaseIterable {
    case forTime    = "For Time"
    case amrap      = "AMRAP"
    case emom       = "EMOM"
    case tabata     = "Tabata"
    case maxLoad    = "Max Load"
    case rft        = "Rounds For Time"
    case strength   = "Strength"     // 5-5-5, 1RM, Wendler cycles
    case intervals  = "Intervals"    // Timed intervals with prescribed rest
    case chipper    = "Chipper"      // Long task-priority with varied movements
    case deathBy    = "Death By"     // Ascending rep scheme each minute
    case complex    = "Complex"      // Bear Complex, Macho Man, etc.
    case custom     = "Custom"
}

// MARK: - WorkoutResult

@Model
final class WorkoutResult {
    var id: UUID
    var workout: Workout?
    var date: Date
    var scoreType: ScoreType
    var timeSeconds: Int?       // For Time results
    var rounds: Int?            // AMRAP results
    var repsRemainder: Int?     // AMRAP remainder reps
    var weight: Double?         // Max load
    var totalReps: Int?         // Total rep count for chipper / rep-only scores
    var notes: String
    var rx: Bool                // Was it Rx or scaled?
    var isPersonalRecord: Bool
    var createdAt: Date

    init(
        workout: Workout,
        date: Date = Date(),
        scoreType: ScoreType,
        timeSeconds: Int? = nil,
        rounds: Int? = nil,
        repsRemainder: Int? = nil,
        weight: Double? = nil,
        totalReps: Int? = nil,
        notes: String = "",
        rx: Bool = true,
        isPersonalRecord: Bool = false
    ) {
        self.id = UUID()
        self.workout = workout
        self.date = date
        self.scoreType = scoreType
        self.timeSeconds = timeSeconds
        self.rounds = rounds
        self.repsRemainder = repsRemainder
        self.weight = weight
        self.totalReps = totalReps
        self.notes = notes
        self.rx = rx
        self.isPersonalRecord = isPersonalRecord
        self.createdAt = Date()
    }

    var displayScore: String {
        switch scoreType {
        case .time:
            guard let t = timeSeconds else { return "-" }
            let h = t / 3600
            let m = (t % 3600) / 60
            let s = t % 60
            if h > 0 {
                return String(format: "%d:%02d:%02d", h, m, s)
            }
            return String(format: "%d:%02d", m, s)
        case .rounds:
            let r = rounds ?? 0
            let reps = repsRemainder ?? 0
            return reps > 0 ? "\(r) rounds + \(reps) reps" : "\(r) rounds"
        case .weight:
            return weight.map { "\(Int($0)) lbs" } ?? "-"
        case .reps:
            return totalReps.map { "\($0) reps" } ?? "-"
        default:
            return notes
        }
    }
}

// MARK: - LiftLog

@Model
final class LiftLog {
    var id: UUID
    var movement: Movement?
    var date: Date
    var sets: [LiftSet]
    var notes: String
    var unit: WeightUnit
    var programType: StrengthProgram?
    var percentageOf1RM: Double?

    init(
        movement: Movement,
        date: Date = Date(),
        sets: [LiftSet] = [],
        notes: String = "",
        unit: WeightUnit = .lbs,
        programType: StrengthProgram? = nil,
        percentageOf1RM: Double? = nil
    ) {
        self.id = UUID()
        self.movement = movement
        self.date = date
        self.sets = sets
        self.notes = notes
        self.unit = unit
        self.programType = programType
        self.percentageOf1RM = percentageOf1RM
    }

    var maxWeight: Double? {
        sets.compactMap { $0.weight }.max()
    }

    var totalVolume: Double {
        sets.reduce(0) { $0 + (($1.weight ?? 0) * Double($1.reps ?? 0)) }
    }
}

@Model
final class LiftSet {
    var id: UUID
    var setNumber: Int
    var reps: Int?
    var weight: Double?
    var distance: Double?   // meters
    var height: Double?     // inches
    var completed: Bool
    var isMax: Bool         // Rep max attempt

    init(
        setNumber: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        distance: Double? = nil,
        height: Double? = nil,
        isMax: Bool = false
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.reps = reps
        self.weight = weight
        self.distance = distance
        self.height = height
        self.completed = false
        self.isMax = isMax
    }
}

enum WeightUnit: String, Codable, CaseIterable {
    case lbs = "lbs"
    case kg  = "kg"

    func convert(_ value: Double, to unit: WeightUnit) -> Double {
        if self == unit { return value }
        return self == .lbs ? value * 0.453592 : value * 2.20462
    }
}

enum StrengthProgram: String, Codable, CaseIterable {
    case wendler531   = "Wendler 5/3/1"
    case fiveByFive   = "5x5"
    case threeByThree = "3x3"
    case rpe          = "RPE Based"
    case custom       = "Custom"
}
