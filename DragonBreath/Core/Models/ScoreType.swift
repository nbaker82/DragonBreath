import Foundation

enum ScoreType: String, Codable, CaseIterable {
    case weight   = "Weight (lbs/kg)"
    case reps     = "Reps"
    case time     = "Time"
    case distance = "Distance"
    case height   = "Height"
    case rounds   = "Rounds + Reps"
}
