import SwiftUI
import SwiftData

// MARK: - Equipment

enum Equipment: String, CaseIterable, Identifiable {
    case barbell       = "Barbell"
    case dumbbells     = "Dumbbells"
    case kettlebells   = "Kettlebells"
    case pullUpBar     = "Pull-up Bar"
    case rings         = "Rings"
    case plyoBox       = "Plyo Box"
    case rower         = "Rower"
    case bike          = "Assault/Echo Bike"
    case jumpRope      = "Jump Rope"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .barbell:     return "scalemass.fill"
        case .dumbbells:   return "dumbbell.fill"
        case .kettlebells: return "figure.strengthtraining.traditional"
        case .pullUpBar:   return "figure.pull.ups"
        case .rings:       return "circle.circle"
        case .plyoBox:     return "square.fill"
        case .rower:       return "figure.rowing"
        case .bike:        return "figure.indoor.cycle"
        case .jumpRope:    return "arrow.trianglehead.2.clockwise.rotate.90"
        }
    }

    /// Keywords used to match movement names from the database
    var movementKeywords: [String] {
        switch self {
        case .barbell:
            return ["Snatch", "Clean", "Jerk", "Squat", "Deadlift", "Press", "Thruster",
                    "Bench", "Cluster", "Bear Complex", "Macho Man", "Wall Ball",
                    "Good Morning", "SDLHP", "Sumo Deadlift High Pull", "Back Squat",
                    "Front Squat", "Overhead Squat"]
        case .dumbbells:
            return ["Dumbbell", "DB "]
        case .kettlebells:
            return ["Kettlebell", "KB ", "Turkish Get-Up", "Swing"]
        case .pullUpBar:
            return ["Pull-up", "Pull Up", "Chest-to-Bar", "Toes-to-Bar", "Toes To Bar",
                    "Hanging Knee", "Bar Muscle-up", "Kipping", "L-Sit Pull"]
        case .rings:
            return ["Ring"]
        case .plyoBox:
            return ["Box Jump", "Box Squat", "Step-up", "Step Up"]
        case .rower:
            return ["Row", "Erg"]
        case .bike:
            return ["Bike", "Cal ", "Calorie"]
        case .jumpRope:
            return ["Double Under", "Single Under", "Jump Rope"]
        }
    }

    /// Movement categories always available (no equipment needed)
    static var bodyweightKeywords: [String] {
        ["Push-up", "Burpee", "Air Squat", "Sit-up", "Lunge", "Handstand",
         "HSPU", "Run", "Sprint", "Walking", "GHD", "Pistol", "V-up",
         "Mountain Climber", "Jump Squat", "Broad Jump"]
    }
}

// MARK: - Custom Workout Builder View

struct CustomWorkoutBuilderView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Movement.name) private var allMovements: [Movement]

    // Step tracking
    @State private var step: BuilderStep = .equipment

    // Equipment selection
    @State private var selectedEquipment: Set<Equipment> = []

    // Workout config
    @State private var workoutType: WorkoutType = .amrap
    @State private var timeCap: Int = 20          // minutes
    @State private var workoutName: String = ""
    @State private var workoutDescription: String = ""
    @State private var isBenchmark = false

    // Movement selection
    @State private var selectedMovements: [Movement] = []

    enum BuilderStep: Int, CaseIterable {
        case equipment, format, movements, name

        var title: String {
            switch self {
            case .equipment:  return "Available Equipment"
            case .format:     return "Workout Format"
            case .movements:  return "Pick Movements"
            case .name:       return "Name & Save"
            }
        }
    }

    // MARK: - Filtered movements based on selected equipment

    var availableMovements: [Movement] {
        let bodyweightKeywords = Equipment.bodyweightKeywords
        let equipmentKeywords  = selectedEquipment.flatMap { $0.movementKeywords }
        let allKeywords        = bodyweightKeywords + equipmentKeywords

        return allMovements.filter { movement in
            allKeywords.contains { kw in
                movement.name.localizedCaseInsensitiveContains(kw)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress indicator
                StepProgressBar(currentStep: step.rawValue, totalSteps: BuilderStep.allCases.count)
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Step content
                switch step {
                case .equipment:  equipmentStep
                case .format:     formatStep
                case .movements:  movementsStep
                case .name:       nameStep
                }
            }
            .navigationTitle(step.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if step == .equipment {
                        Button("Cancel") { dismiss() }
                    } else {
                        Button("Back") { withAnimation { step = BuilderStep(rawValue: step.rawValue - 1)! } }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if step == .name {
                        Button("Save") { save() }
                            .fontWeight(.semibold)
                            .disabled(workoutName.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        Button("Next") { withAnimation { step = BuilderStep(rawValue: step.rawValue + 1)! } }
                            .fontWeight(.semibold)
                            .disabled(step == .movements && selectedMovements.isEmpty)
                    }
                }
            }
        }
    }

    // MARK: - Step 1: Equipment

    private var equipmentStep: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Select the equipment you have available. Bodyweight movements are always included.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(Equipment.allCases) { equipment in
                        EquipmentToggleCard(
                            equipment: equipment,
                            isSelected: selectedEquipment.contains(equipment)
                        ) {
                            if selectedEquipment.contains(equipment) {
                                selectedEquipment.remove(equipment)
                            } else {
                                selectedEquipment.insert(equipment)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Step 2: Format

    private var formatStep: some View {
        Form {
            Section("Workout Type") {
                Picker("Type", selection: $workoutType) {
                    ForEach(WorkoutType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section("Time Cap (minutes)") {
                Stepper("\(timeCap) minutes", value: $timeCap, in: 5...60, step: 5)
            }
        }
    }

    // MARK: - Step 3: Movements

    private var movementsStep: some View {
        Group {
            if availableMovements.isEmpty {
                ContentUnavailableView(
                    "No Movements Found",
                    systemImage: "figure.mixed.cardio",
                    description: Text("Try selecting more equipment on the previous step.")
                )
            } else {
                List {
                    Section {
                        Text("\(availableMovements.count) movements available with your equipment. Tap to select.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    let grouped = Dictionary(grouping: availableMovements) { $0.category.rawValue }
                    ForEach(grouped.keys.sorted(), id: \.self) { category in
                        Section(category) {
                            ForEach(grouped[category]!) { movement in
                                MovementToggleRow(
                                    movement: movement,
                                    isSelected: selectedMovements.contains(where: { $0.id == movement.id })
                                ) {
                                    toggle(movement)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    // MARK: - Step 4: Name & Preview

    private var nameStep: some View {
        Form {
            Section("Workout Name") {
                TextField("e.g. Thursday Grinder", text: $workoutName)
            }

            Section("Description (optional)") {
                TextField("Describe the workout…", text: $workoutDescription, axis: .vertical)
                    .lineLimit(4...10)
            }

            Section {
                Toggle("Mark as Benchmark", isOn: $isBenchmark)
            }

            Section("Preview") {
                LabeledContent("Type", value: workoutType.rawValue)
                LabeledContent("Time Cap", value: "\(timeCap) min")
                LabeledContent("Movements", value: "\(selectedMovements.count) selected")
                if !selectedMovements.isEmpty {
                    Text(selectedMovements.map(\.name).joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func toggle(_ movement: Movement) {
        if let idx = selectedMovements.firstIndex(where: { $0.id == movement.id }) {
            selectedMovements.remove(at: idx)
        } else {
            selectedMovements.append(movement)
        }
    }

    private func save() {
        let name = workoutName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let desc = workoutDescription.trimmingCharacters(in: .whitespaces).isEmpty
            ? autoDescription
            : workoutDescription

        let workout = Workout(
            name: name,
            workoutType: workoutType,
            workoutDescription: desc,
            timeCap: timeCap * 60,
            isBenchmark: isBenchmark,
            movements: selectedMovements
        )
        workoutRepo.save(workout)
        dismiss()
    }

    private var autoDescription: String {
        let movNames = selectedMovements.map(\.name).joined(separator: ", ")
        switch workoutType {
        case .amrap:   return "\(timeCap)-min AMRAP of: \(movNames)"
        case .forTime: return "For Time (\(timeCap)-min cap): \(movNames)"
        case .emom:    return "\(timeCap)-min EMOM: \(movNames)"
        default:       return "\(workoutType.rawValue): \(movNames)"
        }
    }
}

// MARK: - Equipment Toggle Card

private struct EquipmentToggleCard: View {
    let equipment: Equipment
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: equipment.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Color.brand)
                Text(equipment.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .background(isSelected ? Color.brand : Color.brand.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Movement Toggle Row

private struct MovementToggleRow: View {
    let movement: Movement
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(movement.name)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.brand)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// MARK: - Step Progress Bar

private struct StepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? Color.brand : Color.brand.opacity(0.2))
                    .frame(height: 4)
            }
        }
    }
}
