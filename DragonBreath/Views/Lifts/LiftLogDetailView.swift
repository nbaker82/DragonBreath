import SwiftUI

struct LiftLogDetailView: View {
    let log: LiftLog
    let allLogs: [LiftLog]

    var body: some View {
        List {
            Section("Sets") {
                ForEach(log.sets.sorted { $0.setNumber < $1.setNumber }) { set in
                    HStack {
                        Text("Set \(set.setNumber)")
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .leading)

                        if let reps = set.reps {
                            Text("\(reps) reps")
                        }

                        Spacer()

                        if let w = set.weight {
                            Text("\(Int(w)) \(log.unit.rawValue)")
                                .font(.headline)
                                .foregroundStyle(Color.brand)
                        }
                        if let d = set.distance {
                            Text("\(Int(d))m")
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }
                        if let h = set.height {
                            Text("\(Int(h))\"")
                                .font(.headline)
                                .foregroundStyle(.purple)
                        }
                    }
                }
            }

            if let max = log.maxWeight {
                Section("Session Stats") {
                    LabeledContent("Max Weight", value: "\(Int(max)) \(log.unit.rawValue)")
                    LabeledContent("Total Volume", value: "\(Int(log.totalVolume)) \(log.unit.rawValue)")
                    LabeledContent("Sets Completed", value: "\(log.sets.count)")
                }
            }

            if !log.notes.isEmpty {
                Section("Notes") {
                    Text(log.notes)
                }
            }

            if let movement = log.movement {
                let movementLogs = allLogs.filter { $0.movement?.id == movement.id }
                    .sorted { $0.date > $1.date }

                if movementLogs.count > 1 {
                    Section("\(movement.name) History") {
                        ForEach(movementLogs.prefix(10)) { histLog in
                            HStack {
                                Text(histLog.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                if let max = histLog.maxWeight {
                                    Text("\(Int(max)) \(histLog.unit.rawValue)")
                                        .font(.subheadline)
                                        .foregroundStyle(histLog.id == log.id ? Color.brand : .primary)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(log.movement?.name ?? "Lift Log")
        .navigationBarTitleDisplayMode(.large)
    }
}
