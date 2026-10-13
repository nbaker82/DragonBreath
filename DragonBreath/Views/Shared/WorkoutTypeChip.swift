import SwiftUI

struct WorkoutTypeChip: View {
    let type: WorkoutType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? type.themeColor : type.themeColor.opacity(0.15))
                .foregroundStyle(isSelected ? .white : type.themeColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
