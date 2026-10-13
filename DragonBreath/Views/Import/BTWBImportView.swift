import SwiftUI
import UniformTypeIdentifiers

struct BTWBImportView: View {
    @Environment(WorkoutRepository.self) private var workoutRepo
    @Environment(LiftRepository.self) private var liftRepo
    @State private var vm = BTWBImportViewModel()

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
                                Text("Import from btwb")
                                    .font(.headline)
                                Text("Bring your history with you")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("How to Export from btwb") {
                    InstructionRow(number: "1", text: "Open btwb on the web (beyondthewhiteboard.com)")
                    InstructionRow(number: "2", text: "Go to Account Settings → Data Export")
                    InstructionRow(number: "3", text: "Download your Workouts CSV and/or Lifts CSV")
                    InstructionRow(number: "4", text: "Transfer the CSV to your iPhone (Files app, AirDrop, iCloud)")
                    InstructionRow(number: "5", text: "Tap Import below and select your CSV file")
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
                    .listRowBackground(Color.brand)
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
                    Text("DragonBreath supports btwb's standard CSV export format for both workout results and lift/strength logs.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("btwb Import")
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

struct InstructionRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.brand)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
