import SwiftUI

/// The user's light/dark preference. `.system` follows the device setting.
enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark

    /// `@AppStorage` key shared by the app root (which applies it) and the picker.
    static let storageKey = "appearance"

    var id: Self { self }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light:  "sun.max"
        case .dark:   "moon"
        }
    }
}
