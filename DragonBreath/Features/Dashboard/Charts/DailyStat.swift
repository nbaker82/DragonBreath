import SwiftUI

struct DailyStat: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}
