import SwiftUI

// MARK: - Import ViewModel

@MainActor
@Observable
final class ImportViewModel {
    var isImporting: Bool = false
    var importResult: ImportResult? = nil
    var showFilePicker: Bool = false
    var isProcessing: Bool = false

    struct ImportResult {
        var workoutsImported: Int
        var liftsImported: Int
        var errors: [String]
        var success: Bool
        /// Rows skipped because the same result already exists (e.g. re-importing a file).
        var duplicatesSkipped: Int = 0
    }

    func importCSV(url: URL, workoutRepo: WorkoutRepository, liftRepo: LiftRepository) async {
        isProcessing = true
        defer { isProcessing = false }

        // Files picked via fileImporter live outside the sandbox and must be
        // explicitly unlocked before reading.
        guard url.startAccessingSecurityScopedResource() else {
            importResult = ImportResult(workoutsImported: 0, liftsImported: 0,
                                        errors: ["Permission denied reading the selected file."], success: false)
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            guard let content = String(data: data, encoding: .utf8) else {
                importResult = ImportResult(workoutsImported: 0, liftsImported: 0,
                                           errors: ["Could not read file encoding."], success: false)
                return
            }

            let result = CSVImportService.parse(csv: content, workoutRepo: workoutRepo, liftRepo: liftRepo)
            importResult = result
        } catch {
            importResult = ImportResult(workoutsImported: 0, liftsImported: 0,
                                        errors: [error.localizedDescription], success: false)
        }
    }
}
