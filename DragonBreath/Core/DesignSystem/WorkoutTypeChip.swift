import SwiftUI

struct WorkoutTypeChip: View {
    let type: WorkoutType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        // Text stays in primary color for contrast; the type color only tints the
        // fill and border. The checkmark marks selection without relying on color.
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .accessibilityHidden(true)
                }
                Text(type.rawValue)
            }
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .background(type.themeColor.opacity(isSelected ? 0.25 : 0.1), in: .capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(type.themeColor, lineWidth: isSelected ? 1.5 : 0)
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
