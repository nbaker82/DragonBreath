import SwiftUI
import Charts

// MARK: - Chart data models

struct CategoryStat: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
    let color: Color
}
