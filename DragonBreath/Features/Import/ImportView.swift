import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(LiftRepository.self) private var liftRepo
    @Environment(\.dismiss) private var dismiss
    @State private var vm = ImportViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color.brand)
                            VStack(alignment: .leading) {
                                Text("Import from CSV")
                                    .font(.headline)
                                Text("Bring your history with you")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("How to Import") {
                    InstructionRow(number: "1", text: "Export your history as a CSV from another app, or build one in a spreadsheet")
                    InstructionRow(number: "2", text: "Transfer the CSV to your iPhone (Files app, AirDrop, iCloud)")
                    InstructionRow(number: "3", text: "Tap Select CSV File below and choose the file")
                }

                Section("Import") {
                    Button {
                        vm.showFilePicker = true
                    } label: {
                        HStack {
                            if vm.isProcessing {
                                ProgressView()
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "folder.badge.plus")
                            }
                            Text(vm.isProcessing ? "Importing..." : "Select CSV File")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .foregroundStyle(.white)
                    .listRowBackground(Color.brandFill)
                    .disabled(vm.isProcessing)
                }

                // Result
                if let result = vm.importResult {
                    Section("Last Import") {
                        if result.success {
                            if result.workoutsImported > 0 {
                                Label("\(result.workoutsImported) workout results imported", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            if result.liftsImported > 0 {
                                Label("\(result.liftsImported) lift logs imported", systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            if result.workoutsImported == 0 && result.liftsImported == 0 {
                                Label("No new data found in file", systemImage: "info.circle")
                                    .foregroundStyle(.secondary)
                            }
                            if result.duplicatesSkipped > 0 {
                                Label("\(result.duplicatesSkipped) already-imported rows skipped", systemImage: "arrow.triangle.2.circlepath")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Label("Import failed", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }

                        ForEach(result.errors, id: \.self) { error in
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section("Supported Formats") {
                    Text("Workouts: a header row with workout, score, date (MM/DD/YYYY or YYYY-MM-DD), and optionally notes and rx.\nLifts: a header row with movement, weight, reps, date, and optionally notes.\nRows you've already imported are skipped.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Import CSV")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $vm.showFilePicker,
                allowedContentTypes: [UTType.commaSeparatedText, UTType.plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    Task {
                        await vm.importCSV(url: url, workoutRepo: workoutRepo, liftRepo: liftRepo)
                    }
                case .failure(let error):
                    vm.importResult = .init(
                        workoutsImported: 0,
                        liftsImported: 0,
                        errors: [error.localizedDescription],
                        success: false
                    )
                }
            }
        }
    }
}
