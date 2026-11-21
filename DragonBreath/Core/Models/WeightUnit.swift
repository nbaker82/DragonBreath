import Foundation

enum WeightUnit: String, Codable, CaseIterable {
    case lbs = "lbs"
    case kg  = "kg"

    func convert(_ value: Double, to unit: WeightUnit) -> Double {
        if self == unit { return value }
        return self == .lbs ? value * 0.453592 : value * 2.20462
    }
}
