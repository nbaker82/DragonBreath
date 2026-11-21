import SwiftUI
import Charts
import SwiftData

// MARK: - Chart subviews

struct MovementBreakdownChart: View {
    let categoryData: [CategoryStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Movement Breakdown")
                .font(.headline)
                .padding(.horizontal)

            if categoryData.allSatisfy({ $0.count == 0 }) {
                ChartEmptyPlaceholder(message: "No workout data this month")
            } else {
                Chart(categoryData) { stat in
                    BarMark(
                        x: .value("Category", stat.label),
                        y: .value("Count", stat.count)
                    )
                    .foregroundStyle(stat.color)
                    .cornerRadius(6)
                }
                .chartYAxis { AxisMarks(position: .leading) }
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
