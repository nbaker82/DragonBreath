import SwiftUI

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
