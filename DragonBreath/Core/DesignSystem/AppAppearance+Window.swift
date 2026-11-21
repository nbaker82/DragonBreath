import SwiftUI

extension AppAppearance {
    /// Applies the choice to every window. This is used instead of `preferredColorScheme`
    /// because returning that modifier to `nil` doesn't reliably hand control back to the
    /// device setting once Light or Dark was chosen; `.unspecified` does.
    @MainActor
    func applyToWindows() {
        let style: UIUserInterfaceStyle = switch self {
        case .system: .unspecified
        case .light:  .light
        case .dark:   .dark
        }
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            for window in scene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
