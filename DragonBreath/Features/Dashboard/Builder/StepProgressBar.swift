import SwiftUI

// MARK: - Step Progress Bar

struct StepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? Color.brand : Color.brand.opacity(0.2))
                    .frame(height: 4)
            }
        }
    }
}
