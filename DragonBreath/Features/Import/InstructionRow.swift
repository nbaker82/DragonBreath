import SwiftUI

struct InstructionRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Color.brandFill)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}
