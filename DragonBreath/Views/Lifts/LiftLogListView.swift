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

struct LiftLogRowView: View {
    let log: LiftLog

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(log.movement?.name ?? "Unknown")
                    .font(.headline)
                Spacer()
                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                if let max = log.maxWeight {
                    Label("\(Int(max)) \(log.unit.rawValue)", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.brand)
                }
                Text("\(log.sets.count) set\(log.sets.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct MovementFilterMenu: View {
    @Bindable var vm: LiftLogViewModel
    let movements: [Movement]

    var body: some View {
        Menu {
            Button("All Movements") { vm.selectedMovement = nil }
            Divider()
            ForEach(movements) { movement in
                Button(movement.name) { vm.selectedMovement = movement }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .foregroundStyle(vm.selectedMovement != nil ? Color.brand : .primary)
        }
    }
}
