import SwiftUI

// MARK: - Brand Colors

extension Color {
    /// Deep red-orange — the primary fire color.
    static let brand      = Color(red: 1.0,  green: 0.27, blue: 0.0)   // #FF4500
    /// Amber — the secondary fire color.
    static let brandAmber = Color(red: 1.0,  green: 0.58, blue: 0.0)   // #FF9500
    /// Gold — used for PR badges and the Dragon rank.
    static let brandGold  = Color(red: 1.0,  green: 0.84, blue: 0.0)   // #FFD700

    /// Elevated card surface — maps to the system secondary background.
    static let cardSurface  = Color(.secondarySystemBackground)
    /// Nested surface — maps to the system tertiary background.
    static let cardSurface2 = Color(.tertiarySystemBackground)
}

// MARK: - Gradients

extension LinearGradient {
    /// Horizontal fire gradient: deep red-orange → amber.
    static let fire = LinearGradient(
        colors: [.brand, .brandAmber],
        startPoint: .leading, endPoint: .trailing
    )

    /// Vertical fire gradient for chart area fills (fades to clear at the bottom).
    static let fireArea = LinearGradient(
        colors: [Color.brand.opacity(0.5), Color.brand.opacity(0.05)],
        startPoint: .top, endPoint: .bottom
    )

    /// Gold shimmer — used on Dragon rank and PR badges.
    static let gold = LinearGradient(
        colors: [Color.brandGold, Color(red: 1.0, green: 0.55, blue: 0.0)],
        startPoint: .leading, endPoint: .trailing
    )
}

// MARK: - Workout Type Color

extension WorkoutType {
    /// Categorical color used for chips, banners, and badges.
    var themeColor: Color {
        switch self {
        case .amrap:                            return .brand
        case .emom:                             return .blue
        case .forTime, .rft, .chipper:          return Color(red: 0.18, green: 0.8, blue: 0.44) // emerald
        case .tabata:                           return .purple
        case .deathBy:                          return Color(red: 0.9, green: 0.2, blue: 0.2)
        case .maxLoad, .strength, .complex:     return Color(red: 0.4, green: 0.4, blue: 0.9)   // indigo-ish
        case .intervals:                        return .teal
        default:                                return .gray
        }
    }
}
