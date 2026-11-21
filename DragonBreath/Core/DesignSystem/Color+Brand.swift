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
