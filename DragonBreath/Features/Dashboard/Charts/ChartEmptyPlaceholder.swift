import SwiftUI

/// Centered message shown in a chart card when there's nothing to plot yet.
struct ChartEmptyPlaceholder: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 80)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}
