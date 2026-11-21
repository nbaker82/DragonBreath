import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \WorkoutResult.date, order: .reverse) private var results: [WorkoutResult]
    @Query(sort: \LiftLog.date, order: .reverse) private var liftLogs: [LiftLog]

    @State private var selectedSegment: Int = 0
    let segments = ["Workouts", "Lifts"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Segment", selection: $selectedSegment) {
                    ForEach(0..<segments.count, id: \.self) { i in
                        Text(segments[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedSegment == 0 {
                    WorkoutHistoryView(results: results)
                } else {
                    LiftHistoryView(logs: liftLogs)
                }
            }
            .navigationTitle("History")
        }
    }
}
