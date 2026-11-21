import SwiftUI

struct StatCard: View {
    let title: String
    let value: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // Compact column for side-by-side cards; at accessibility sizes the cards are
        // stacked full width, so a title-left / value-right row reads better.
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let layout = isLarge
            ? AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 12))
            : AnyLayout(VStackLayout(spacing: 4))

        layout {
            if isLarge {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(LinearGradient.fire)
            if !isLarge {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, isLarge ? 16 : 4)
        .background(Color.cardSurface)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.brand.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
