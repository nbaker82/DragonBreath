import SwiftUI
import SwiftData

// MARK: - Movement Toggle Row

struct MovementToggleRow: View {
    let movement: Movement
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(movement.name)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.brand)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}
