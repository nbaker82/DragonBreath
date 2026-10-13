import SwiftUI
import Charts

struct LiftHistoryView: View {
    let logs: [LiftLog]

    var grouped: [(String, [LiftLog])] {
        let dict = Dictionary(grouping: logs) { $0.movement?.name ?? "Unknown" }
        return dict.sorted { $0.key < $1.key }
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 20) {
                    StatCard(title: "Total Sessions", value: "\(logs.count)")
                    StatCard(title: "Movements", value: "\(grouped.count)")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            ForEach(grouped, id: \.0) { movName, movLogs in
                Section {
                    let data = movLogs.sorted { $0.date < $1.date }
                        .compactMap { log -> (Date, Double)? in
                            guard let max = log.maxWeight else { return nil }
                            return (log.date, max)
                        }

                    if data.count >= 2 {
                        Chart {
                            ForEach(data, id: \.0) { point in
                                LineMark(
                                    x: .value("Date", point.0),
                                    y: .value("Weight", point.1)
                                )
                                .foregroundStyle(Color.brand)
                                PointMark(
                                    x: .value("Date", point.0),
                                    y: .value("Weight", point.1)
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

                    if let best = movLogs.compactMap({ $0.maxWeight }).max() {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(Color.brand)
                                .font(.caption)
                            Text("Best: \(Int(best)) lbs")
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
