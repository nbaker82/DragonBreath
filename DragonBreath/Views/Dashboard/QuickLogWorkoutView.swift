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

    @State private var date = Date()
    @State private var rx = true
    @State private var workoutName = ""
    @State private var notes = ""

    @State private var timeMinutes = ""
    @State private var timeSeconds = ""
    @State private var rounds = ""
    @State private var repsRemainder = ""
    @State private var weight = ""
    @State private var totalReps = ""

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

                scoreSection

                Section("Details") {
                    TextField("Workout name (optional)", text: $workoutName)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Rx", isOn: $rx)
                }

                Section("Notes") {
                    TextField("How did it feel? Any notes…", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log What I Did")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showMovementPicker) {
                MovementPickerSheet(allMovements: allMovements, selected: $selectedMovements)
            }
        }
    }

    @ViewBuilder
    private var scoreSection: some View {
        switch workoutType {
        case .forTime, .rft, .chipper:
            Section {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MIN").font(.caption2).foregroundStyle(.secondary)
                        TextField("00", text: $timeMinutes)
                            .keyboardType(.numberPad)
                            .font(.title2.monospacedDigit())
                    }
                    Text(":").font(.title2.bold()).foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SEC").font(.caption2).foregroundStyle(.secondary)
                        TextField("00", text: $timeSeconds)
                            .keyboardType(.numberPad)
                            .font(.title2.monospacedDigit())
                    }
                }
                .padding(.vertical, 4)
            } header: { Text("Finishing Time") } footer: {
                Text("Log the time it took you to finish.")
            }

        case .amrap:
            Section {
                LabeledContent("Rounds") {
                    TextField("0", text: $rounds).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Extra Reps") {
                    TextField("0", text: $repsRemainder).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                Text("AMRAP in \(timeCap) min — log total complete rounds + any extra reps.")
            }

        case .emom:
            Section {
                LabeledContent("Rounds Completed") {
                    TextField("0", text: $rounds).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Extra Reps") {
                    TextField("0", text: $repsRemainder).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                Text("EMOM — \(timeCap) rounds total. Log how many intervals you completed successfully.")
            }

        case .tabata:
            Section {
                LabeledContent("Total Reps") {
                    TextField("0", text: $totalReps).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                Text("Tabata: 8 rounds × 20 sec on / 10 sec off. Log total reps across all rounds.")
            }

        case .deathBy:
            Section {
                LabeledContent("Rounds Reached") {
                    TextField("0", text: $rounds).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
                LabeledContent("Reps in Final Round") {
                    TextField("0", text: $repsRemainder).keyboardType(.numberPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Score") } footer: {
                Text("Log the last round you completed + reps into your failed round.")
            }

        case .maxLoad, .strength, .complex:
            Section {
                LabeledContent("Weight (lbs)") {
                    TextField("0", text: $weight).keyboardType(.decimalPad).multilineTextAlignment(.trailing)
                }
            } header: { Text("Best Load") }

        default:
            Section("Score / Notes") {
                TextField("Describe your result…", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            }
        }
    }

    private var needsTimeCap: Bool {
        switch workoutType {
        case .amrap, .emom, .forTime, .rft, .chipper, .tabata, .intervals, .deathBy: return true
        default: return false
        }
    }

    private func save() {
        let name = workoutName.trimmingCharacters(in: .whitespaces).isEmpty
            ? autoName : workoutName.trimmingCharacters(in: .whitespaces)

        let workout = Workout(
            name: name,
            workoutType: workoutType,
            workoutDescription: autoDescription,
            timeCap: needsTimeCap ? timeCap * 60 : nil,
            movements: selectedMovements
        )
        var timeSecondsVal: Int? = nil
        var roundsInt: Int? = nil
        var repsInt: Int? = nil
        var weightDouble: Double? = nil
        var totalRepsInt: Int? = nil
        let scoreType: ScoreType

        switch workoutType {
        case .forTime, .rft, .chipper:
            let m = Int(timeMinutes) ?? 0
            let s = Int(timeSeconds) ?? 0
            timeSecondsVal = m * 60 + s
            scoreType = .time
        case .amrap, .emom, .deathBy:
            roundsInt = Int(rounds)
            repsInt = Int(repsRemainder)
            scoreType = .rounds
        case .tabata:
            totalRepsInt = Int(totalReps)
            scoreType = .reps
        case .maxLoad, .strength, .complex:
            weightDouble = Double(weight)
            scoreType = .weight
        default:
            scoreType = .reps
        }

        let result = WorkoutResult(
            workout: workout,
            date: date,
            scoreType: scoreType,
            timeSeconds: timeSecondsVal,
            rounds: roundsInt,
            repsRemainder: repsInt,
            weight: weightDouble,
            totalReps: totalRepsInt,
            notes: notes,
            rx: rx
        )
        workoutRepo.saveWorkoutAndResult(workout, result: result)
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
