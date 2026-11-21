import SwiftUI

/// Menu picker for System / Light / Dark. Shown as a submenu inside a `Menu`.
struct AppearancePicker: View {
    @AppStorage(AppAppearance.storageKey) private var appearance: AppAppearance = .system

    var body: some View {
        Picker(selection: $appearance) {
            ForEach(AppAppearance.allCases) { option in
                Label(option.title, systemImage: option.systemImage)
                    .tag(option)
            }
        } label: {
            Label("Appearance", systemImage: "circle.lefthalf.filled")
        }
        .pickerStyle(.menu)
    }
}
