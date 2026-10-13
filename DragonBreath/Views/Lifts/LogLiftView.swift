import SwiftUI
import SwiftData

struct LogLiftView: View {
    @Environment(LiftRepository.self) private var liftRepo
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Movement.name) private var movements: [Movement]
    @Query(sort: \LiftLog.date, order: .reverse) private var allLogs: [LiftLog]

    @State private var vm = LogLiftViewModel()

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
                        LiftSetRowEditor(set: set, unit: vm.unit)
                    }
                    .onDelete { vm.removeSet(at: $0) }

                    Button {
                        vm.addSet()
                    } label: {
                        Label("Add Set", systemImage: "plus.circle")
                    }
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
                }
            }
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
                    .fontWeight(.semibold)
                    .disabled(vm.movement == nil)
                }
            }
        }
    }
}

struct LiftSetRowEditor: View {
    @Bindable var set: LiftSet
    let unit: WeightUnit

    @State private var weightStr: String = ""
    @State private var repsStr: String = ""

    var body: some View {
        HStack {
            Text("Set \(set.setNumber)")
                .foregroundStyle(.secondary)
                .frame(width: 50)

            TextField("Reps", text: $repsStr)
                .keyboardType(.numberPad)
                .onChange(of: repsStr) { set.reps = Int($1) }

            Text("×")
                .foregroundStyle(.secondary)

            TextField("Weight (\(unit.rawValue))", text: $weightStr)
                .keyboardType(.decimalPad)
                .onChange(of: weightStr) { set.weight = Double($1) }
        }
        .onAppear {
            if let w = set.weight { weightStr = String(Int(w)) }
            if let r = set.reps { repsStr = String(r) }
        }
    }
}
