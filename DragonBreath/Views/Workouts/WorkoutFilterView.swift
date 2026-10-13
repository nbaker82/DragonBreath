import SwiftUI

struct WorkoutFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vm: WorkoutListViewModel
    let movements: [Movement]

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Workout Type", selection: $vm.selectedType) {
                        Text("All Types").tag(Optional<WorkoutType>.none)
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(Optional(type))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Movement") {
                    Picker("Movement", selection: $vm.selectedMovement) {
                        Text("All Movements").tag(Optional<Movement>.none)
                        ForEach(movements) { movement in
                            Text(movement.name).tag(Optional(movement))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Options") {
                    Toggle("Benchmarks Only", isOn: $vm.showBenchmarksOnly)
                }

                Section {
                    Button("Clear Filters", role: .destructive) {
                        vm.selectedType = nil
                        vm.selectedMovement = nil
                        vm.showBenchmarksOnly = false
                    }
                }
            }
            .navigationTitle("Filter Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
