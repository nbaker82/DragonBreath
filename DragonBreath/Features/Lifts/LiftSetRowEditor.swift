import SwiftUI
import SwiftData

struct LiftSetRowEditor: View {
    @Bindable var set: LiftSet
    let unit: WeightUnit
    var focus: FocusState<LogLiftView.Field?>.Binding

    @State private var weightStr: String = ""
    @State private var repsStr: String = ""
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Fixed widths (scaled with Dynamic Type) so the Spacer can't squeeze the fields.
    @ScaledMetric private var repsFieldWidth = 40.0
    @ScaledMetric private var weightFieldWidth = 64.0

    var body: some View {
        // Each value carries a visible unit label, so filled-in rows still read "8 reps × 135 lbs".
        // At accessibility text sizes the row stacks vertically instead of squeezing the labels.
        let isLarge = dynamicTypeSize.isAccessibilitySize
        let layout = isLarge
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: 8))

        layout {
            Text("Set \(set.setNumber)")
                .monospacedDigit()
                .foregroundStyle(.secondary)

            if !isLarge {
                Spacer(minLength: 4)
            }

            HStack(spacing: 8) {
                TextField("0", text: $repsStr)
                    .keyboardType(.numberPad)
                    .modifier(NumberFieldStyle(width: repsFieldWidth))
                    .focused(focus, equals: .reps(set.id))
                    .accessibilityLabel("Set \(set.setNumber) reps")
                    .onChange(of: repsStr) { set.reps = Int($1) }
                Text("reps")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }

            if !isLarge {
                Text("×")
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 8) {
                TextField("0", text: $weightStr)
                    .keyboardType(.decimalPad)
                    .modifier(NumberFieldStyle(width: weightFieldWidth))
                    .focused(focus, equals: .weight(set.id))
                    .accessibilityLabel("Set \(set.setNumber) weight in \(unit.rawValue)")
                    .onChange(of: weightStr) { set.weight = Self.parseWeight($1) }
                Text(unit.rawValue)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .onAppear {
            // Keep the fractional part (e.g. 102.5) so the round-trip through onChange doesn't truncate it.
            if let w = set.weight { weightStr = w.formatted(.number.grouping(.never)) }
            if let r = set.reps { repsStr = String(r) }
        }
    }

    /// Locale-aware parse so "102,5" works where the decimal pad shows a comma.
    private static func parseWeight(_ text: String) -> Double? {
        try? Double(text, format: .number.grouping(.never))
    }
}
