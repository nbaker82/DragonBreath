import SwiftUI
import SwiftData

struct LogLiftView: View {
    @Environment(LiftRepository.self) private var liftRepo
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Movement.name) private var movements: [Movement]
    @Query(sort: \LiftLog.date, order: .reverse) private var allLogs: [LiftLog]

    @State private var vm = LogLiftViewModel()
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case reps(UUID), weight(UUID), notes
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Movement") {
                    Picker("Movement", selection: $vm.movement) {
                        Text("Select movement").tag(Optional<Movement>.none)
                        ForEach(movements) { movement in
                            Text(movement.name).tag(Optional(movement))
                        }
                    }

                    DatePicker("Date", selection: $vm.date, displayedComponents: .date)

                    Picker("Unit", selection: $vm.unit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Sets") {
                    ForEach(vm.sets) { set in
                        LiftSetRowEditor(set: set, unit: vm.unit, focus: $focusedField)
                    }
                    .onDelete { vm.removeSet(at: $0) }

                    Button("Add Set", systemImage: "plus.circle", action: vm.addSet)
                        .foregroundStyle(Color.brand)
                }

                if vm.movement != nil, vm.currentMaxWeight != nil {
                    Section {
                        Text(vm.percentileLabel(logs: allLogs))
                            .font(.subheadline)
                            .foregroundStyle(Color.brand)
                    }
                }

                Section("Notes") {
                    TextField("Optional notes...", text: $vm.notes, axis: .vertical)
                        .lineLimit(2...4)
                        .focused($focusedField, equals: .notes)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Log Lift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        vm.save(repo: liftRepo)
                        dismiss()
                    }
                    .disabled(vm.movement == nil)
                }
                // Number pads have no return key, so give them an explicit way out.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }
}

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
