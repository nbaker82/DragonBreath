import SwiftUI
import SwiftData

struct QuickLogWorkoutView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Movement.name) private var allMovements: [Movement]

    @State private var workoutType: WorkoutType = .amrap
    @State private var timeCap: Int = 20
    @State private var selectedMovements: [Movement] = []
    @State private var showMovementPicker = false

    @State private var date = Date.now
    @State private var rx = true
    @State private var workoutName = ""
    @State private var notes = ""

    @State private var score = ScoreEntry()

    @FocusState private var focusedField: ScoreField?

    var body: some View {
        NavigationStack {
            Form {
                Section("What type of workout?") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(WorkoutType.allCases, id: \.self) { type in
                                WorkoutTypeChip(type: type, isSelected: workoutType == type) {
                                    workoutType = type
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                }

                if needsTimeCap {
                    Section {
                        Stepper("\(timeCap) minutes", value: $timeCap, in: 1...90, step: 1)
                    } header: {
                        Text(workoutType == .emom ? "Duration" : "Time Cap")
                    }
                }

                Section {
                    if selectedMovements.isEmpty {
                        Button {
                            showMovementPicker = true
                        } label: {
                            Label("Add movements…", systemImage: "plus.circle")
                                .foregroundStyle(Color.brand)
                        }
                    } else {
                        ForEach(selectedMovements) { movement in
                            Text(movement.name)
                        }
                        .onDelete { idx in selectedMovements.remove(atOffsets: idx) }
                        .onMove { from, to in selectedMovements.move(fromOffsets: from, toOffset: to) }

                        Button {
                            showMovementPicker = true
                        } label: {
                            Label("Add more…", systemImage: "plus.circle")
                                .foregroundStyle(Color.brand)
                        }
                    }
                } header: {
                    Text("Movements")
                } footer: {
                    if !selectedMovements.isEmpty {
                        Text("Swipe to remove · drag to reorder")
                    }
                }

                ScoreEntrySection(
                    workoutType: workoutType,
                    timeCapMinutes: needsTimeCap ? timeCap : nil,
                    entry: $score,
                    notes: $notes,
                    focus: $focusedField
                )

                Section("Details") {
                    TextField("Workout name (optional)", text: $workoutName).focused($focusedField, equals: .workoutName)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Rx", isOn: $rx)
                }

                Section("Notes") {
                    TextField("How did it feel? Any notes…", text: $notes, axis: .vertical).focused($focusedField, equals: .notes)
                        .lineLimit(3...6)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Log What I Did")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(score.secondsAreInvalid(for: workoutType))
                }
                // Number pads have no return key, so give them an explicit way out.
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done", action: dismissKeyboard)
                }
            }
            .sheet(isPresented: $showMovementPicker) {
                MovementPickerSheet(allMovements: allMovements, selected: $selectedMovements)
            }
        }
    }

    private var needsTimeCap: Bool {
        switch workoutType {
        case .amrap, .emom, .forTime, .rft, .chipper, .tabata, .intervals, .deathBy: return true
        default: return false
        }
    }

    private func dismissKeyboard() {
        focusedField = nil
    }

    private func save() {
        let name = workoutName.trimmingCharacters(in: .whitespaces).isEmpty
            ? autoName : workoutName.trimmingCharacters(in: .whitespaces)

        let workout = Workout(
            name: name,
            workoutType: workoutType,
            workoutDescription: autoDescription,
            timeCap: needsTimeCap ? timeCap * 60 : nil
        )
        let result = WorkoutResult(
            workout: workout,
            date: date,
            score: score.score(for: workoutType),
            notes: notes,
            rx: rx
        )
        workoutRepo.saveWorkoutAndResult(workout, movements: selectedMovements, result: result)
        dismiss()
    }

    private var autoName: String {
        "\(workoutType.rawValue) · \(date.formatted(.dateTime.month(.abbreviated).day()))"
    }

    private var autoDescription: String {
        let movNames = selectedMovements.map(\.name).joined(separator: ", ")
        guard !movNames.isEmpty else { return workoutType.rawValue }
        switch workoutType {
        case .amrap:   return "\(timeCap)-min AMRAP: \(movNames)"
        case .emom:    return "\(timeCap)-min EMOM: \(movNames)"
        case .forTime: return "For Time (\(timeCap)-min cap): \(movNames)"
        default:       return "\(workoutType.rawValue): \(movNames)"
        }
    }
}
