import SwiftUI
import Charts

struct WorkoutsPerDayChart: View {
    let dailyData: [DailyStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workouts This Month")
                .font(.headline)
                .padding(.horizontal)

            if dailyData.isEmpty || dailyData.allSatisfy({ $0.count == 0 }) {
                ChartEmptyPlaceholder(message: "No workouts logged yet this month")
            } else {
                Chart(dailyData) { stat in
                    LineMark(
                        x: .value("Day", stat.date, unit: .day),
                        y: .value("Workouts", stat.count)
                    )
                    .foregroundStyle(LinearGradient.fire)
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Day", stat.date, unit: .day),
                        y: .value("Workouts", stat.count)
                    )
                    .foregroundStyle(LinearGradient.fireArea)
                    .interpolationMethod(.monotone)

                    PointMark(
                        x: .value("Day", stat.date, unit: .day),
                        y: .value("Workouts", stat.count)
                    )
                    .foregroundStyle(Color.brand)
                    .symbolSize(stat.count > 0 ? 40 : 0)
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
                }
                .frame(height: 180)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.brand.opacity(0.15), lineWidth: 1))
    }
}
