import SwiftUI
import Charts

struct LiftHistoryView: View {
    let logs: [LiftLog]
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var grouped: [(String, [LiftLog])] {
        let dict = Dictionary(grouping: logs) { $0.movement?.name ?? "Unknown" }
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        List {
            Section {
                // Stack the stat cards at accessibility sizes so they aren't squeezed.
                (dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 12))
                    : AnyLayout(HStackLayout(alignment: .top, spacing: 20))) {
                    StatCard(title: "Total Sessions", value: "\(logs.count)")
                    StatCard(title: "Movements", value: "\(grouped.count)")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            ForEach(grouped, id: \.0) { movName, movLogs in
                Section {
                    // Show every log in the unit of the most recent session so kg and lbs never mix.
                    let displayUnit = movLogs.max { $0.date < $1.date }?.unit ?? .lbs
                    let data = movLogs.sorted { $0.date < $1.date }
                        .compactMap { log -> (id: UUID, date: Date, weight: Double)? in
                            guard let max = log.maxWeight(in: displayUnit) else { return nil }
                            return (log.id, log.date, max)
                        }

                    if data.count >= 2 {
                        Chart {
                            // Identify by log, not date: imported logs often share a midnight timestamp.
                            ForEach(data, id: \.id) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Weight", point.weight)
                                )
                                .foregroundStyle(Color.brand)
                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("Weight", point.weight)
                                )
                                .foregroundStyle(Color.brand)
                            }
                        }
                        .chartXAxis(.hidden)
                        .chartYAxis {
                            AxisMarks(position: .trailing)
                        }
                        .frame(height: 80)
                        .padding(.vertical, 4)
                    }

                    if let best = data.map(\.weight).max() {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(Color.brand)
                                .font(.caption)
                            Text("Best: \(best.formatted(.number.precision(.fractionLength(0...1)))) \(displayUnit.rawValue)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                } header: {
                    Text(movName)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
