import SwiftUI
import SwiftData

// MARK: - Equipment

enum Equipment: String, CaseIterable, Identifiable {
    case barbell       = "Barbell"
    case dumbbells     = "Dumbbells"
    case kettlebells   = "Kettlebells"
    case pullUpBar     = "Pull-up Bar"
    case rings         = "Rings"
    case plyoBox       = "Plyo Box"
    case rower         = "Rower"
    case bike          = "Assault/Echo Bike"
    case jumpRope      = "Jump Rope"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .barbell:     return "scalemass.fill"
        case .dumbbells:   return "dumbbell.fill"
        case .kettlebells: return "figure.strengthtraining.traditional"
        case .pullUpBar:   return "figure.pull.ups"
        case .rings:       return "circle.circle"
        case .plyoBox:     return "square.fill"
        case .rower:       return "figure.rowing"
        case .bike:        return "figure.indoor.cycle"
        case .jumpRope:    return "arrow.trianglehead.2.clockwise.rotate.90"
        }
    }

    /// Keywords used to match movement names from the database
    var movementKeywords: [String] {
        switch self {
        case .barbell:
            return ["Snatch", "Clean", "Jerk", "Squat", "Deadlift", "Press", "Thruster",
                    "Bench", "Cluster", "Bear Complex", "Macho Man", "Wall Ball",
                    "Good Morning", "SDLHP", "Sumo Deadlift High Pull", "Back Squat",
                    "Front Squat", "Overhead Squat"]
        case .dumbbells:
            return ["Dumbbell", "DB "]
        case .kettlebells:
            return ["Kettlebell", "KB ", "Turkish Get-Up", "Swing"]
        case .pullUpBar:
            return ["Pull-up", "Pull Up", "Chest-to-Bar", "Toes-to-Bar", "Toes To Bar",
                    "Hanging Knee", "Bar Muscle-up", "Kipping", "L-Sit Pull"]
        case .rings:
            return ["Ring"]
        case .plyoBox:
            return ["Box Jump", "Box Squat", "Step-up", "Step Up"]
        case .rower:
            return ["Row", "Erg"]
        case .bike:
            return ["Bike", "Cal ", "Calorie"]
        case .jumpRope:
            return ["Double Under", "Single Under", "Jump Rope"]
        }
    }

    /// Movement categories always available (no equipment needed)
    static var bodyweightKeywords: [String] {
        ["Push-up", "Burpee", "Air Squat", "Sit-up", "Lunge", "Handstand",
         "HSPU", "Run", "Sprint", "Walking", "GHD", "Pistol", "V-up",
         "Mountain Climber", "Jump Squat", "Broad Jump"]
    }
}
