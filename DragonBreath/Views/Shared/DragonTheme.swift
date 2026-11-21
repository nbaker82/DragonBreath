import SwiftUI

// MARK: - Brand Colors

// Brand colors adapt to light and dark mode via the asset catalog. Light variants are
// darkened so text and icons meet WCAG contrast on system backgrounds.

extension Color {
    /// Red-orange — the primary fire color for text, icons, and tint.
    /// Light #C83600 (5.3:1 on white) · Dark #FF5A1F.
    static let brand      = Color("ThemeBrand")
    /// Deep orange for filled backgrounds behind white text, in both modes (#C83600, 5.3:1).
    static let brandFill  = Color("ThemeBrandFill")
    /// Amber — the secondary fire color. Light #B85C00 · Dark #FF9F0A.
    static let brandAmber = Color("ThemeBrandAmber")
    /// Gold — used for PR badges and the Dragon rank. Light #8A5A00 · Dark #FFD60A.
    static let brandGold  = Color("ThemeBrandGold")

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
        colors: [Color.brandGold, Color.brandAmber],
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
