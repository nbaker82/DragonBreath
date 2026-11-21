import SwiftUI

// MARK: - Equipment Toggle Card

struct EquipmentToggleCard: View {
    let equipment: Equipment
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: equipment.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Color.brand)
                Text(equipment.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .background(isSelected ? Color.brandFill : Color.brand.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
