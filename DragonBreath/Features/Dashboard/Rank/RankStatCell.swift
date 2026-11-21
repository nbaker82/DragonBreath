import SwiftUI

// MARK: - Rank Stat Cell

struct RankStatCell: View {
    let value: String
    let label: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Column inside the three-across row; label-left / value-right row when stacked.
        if dynamicTypeSize.isAccessibilitySize {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 8)
                Text(value)
                    .font(.title3.bold())
            }
            .accessibilityElement(children: .combine)
        } else {
            VStack(spacing: 2) {
                Text(value)
                    .font(.title3.bold())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)
        }
    }
}
