import SwiftUI

/// Compact, visibly editable box for short numeric entries in form rows.
struct NumberFieldStyle: ViewModifier {
    /// Exact content width; when nil the field flexes between 44 and 72 points.
    var width: Double? = nil

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.trailing)
            .monospacedDigit()
            .frame(minWidth: width ?? 44, maxWidth: width ?? 72, minHeight: 36)
            .padding(.horizontal, 8)
            .background(.fill.tertiary, in: .rect(cornerRadius: 8))
    }
}
