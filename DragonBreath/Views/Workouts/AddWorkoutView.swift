import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Movement.name) private var movements: [Movement]

    @State private var name: String = ""
    @State private var workoutType: WorkoutType = .forTime
    @State private var description: String = ""
    @State private var isBenchmark: Bool = false
    @State private var selectedMovements: Set<Movement> = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Workout Name", text: $name)
                    Picker("Type", selection: $workoutType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Toggle("Benchmark WOD", isOn: $isBenchmark)
                }

                Section("Description") {
                    TextField("Describe the workout...", text: $description, axis: .vertical)
                        .lineLimit(5...12)
                }

                Section("Movements") {
                    ForEach(movements) { movement in
                        HStack {
                            Text(movement.name)
                            Spacer()
                            if selectedMovements.contains(movement) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.brand)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedMovements.contains(movement) {
                                selectedMovements.remove(movement)
                            } else {
                                selectedMovements.insert(movement)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }

    private func save() {
        let workout = Workout(
            name: name,
            workoutType: workoutType,
            workoutDescription: description,
            isBenchmark: isBenchmark,
            movements: Array(selectedMovements)
        )
        workoutRepo.save(workout)
        dismiss()
    }
}
