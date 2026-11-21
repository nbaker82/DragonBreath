import SwiftUI

// MARK: - Export Helper

struct AppIconExportView: View {
    @State private var exportURL: URL?
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            AppIconView()
                .frame(width: 300, height: 300)

            if let exportURL {
                ShareLink(item: exportURL) {
                    Label("Share / Save PNG", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.brandFill)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            } else {
                Button {
                    renderIcon()
                } label: {
                    Label("Render Icon", systemImage: "wand.and.stars")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.brandFill)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Text("Tap Render, then Share to AirDrop or save the PNG.\nDrag it into Assets.xcassets → AppIcon.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    @MainActor
    private func renderIcon() {
        let renderer = ImageRenderer(content: AppIconView().frame(width: 1024, height: 1024))
        renderer.scale = 1.0
        guard let uiImage = renderer.uiImage,
              let pngData = uiImage.pngData() else {
            errorMessage = "Failed to render icon."
            return
        }
        // Save to Documents so Xcode can pull it out via Download Container
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent("DragonBreath-Icon-1024.png")
        do {
            try pngData.write(to: url)
            exportURL = url
            errorMessage = "Saved! Now: Xcode → Window → Devices & Simulators → ⚙️ → Download Container"
        } catch {
            errorMessage = "Failed to write file: \(error.localizedDescription)"
        }
    }
}
