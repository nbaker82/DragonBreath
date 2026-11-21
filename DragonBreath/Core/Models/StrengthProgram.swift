import Foundation

enum StrengthProgram: String, Codable, CaseIterable {
    case wendler531   = "Wendler 5/3/1"
    case fiveByFive   = "5x5"
    case threeByThree = "3x3"
    case rpe          = "RPE Based"
    case custom       = "Custom"
}
