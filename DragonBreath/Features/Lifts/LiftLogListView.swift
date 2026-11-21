import SwiftUI
import SwiftData

struct LiftLogListView: View {
    @Environment(LiftRepository.self) private var liftRepo
    @Query(sort: \LiftLog.date, order: .reverse) private var logs: [LiftLog]
    @Query(sort: \Movement.name) private var movements: [Movement]

    @State private var vm = LiftLogViewModel()
    @State private var showingAddLog = false

    var body: some View {
        NavigationStack {
            Group {
                if logs.isEmpty {
                    ContentUnavailableView("No Lifts Logged", systemImage: "dumbbell",
                        description: Text("Start tracking your strength progress."))
                } else {
                    List {
                        ForEach(vm.filtered(logs)) { log in
                            NavigationLink(destination: LiftLogDetailView(log: log, allLogs: logs)) {
                                LiftLogRowView(log: log)
                            }
                        }
                        .onDelete(perform: deleteLogs)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Lifts")
            .searchable(text: $vm.searchText, prompt: "Search movements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    MovementFilterMenu(vm: vm, movements: movements)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showingAddLog.toggle() } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLog) {
                LogLiftView()
            }
        }
    }

    private func deleteLogs(at offsets: IndexSet) {
        let filtered = vm.filtered(logs)
        for index in offsets {
            liftRepo.delete(filtered[index])
        }
    }
}
