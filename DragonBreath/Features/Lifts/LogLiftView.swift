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
