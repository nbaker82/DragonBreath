import SwiftUI
import SwiftData

// MARK: - Workout Type Color

extension WorkoutType {
    /// Categorical color used for chips, banners, and badges. Adapts to light/dark mode.
    var themeColor: Color {
        switch self {
        case .amrap:                            return .brand
        case .emom:                             return .blue
        case .forTime, .rft, .chipper:          return Color("ThemeTypeEmerald")
        case .tabata:                           return .purple
        case .deathBy:                          return Color("ThemeTypeRed")
        case .maxLoad, .strength, .complex:     return Color("ThemeTypeIndigo")
        case .intervals:                        return .teal
        default:                                return .gray
        }
    }
}
