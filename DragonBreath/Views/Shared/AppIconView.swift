import SwiftUI

// MARK: - App Icon Design
//
// Design: Bold "D" lettermark with a flame rising from the top.
// Reads clearly at every size from 29pt → 1024pt.
//
// To export:
//  1. Run the app on a simulator or device.
//  2. Open AppIconExportView (visible in the preview below).
//  3. Tap "Save to Photos" — a 1024×1024 PNG lands in your photo library.
//  4. Drag it into Assets.xcassets → AppIcon → the universal slot.

struct AppIconView: View {

    var body: some View {
        ZStack {
            // ── Background ──────────────────────────────────────────────
            Color(red: 0.06, green: 0.06, blue: 0.08)

            // ── Warm glow behind the letter ─────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.35, blue: 0.0).opacity(0.28),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 420
                    )
                )
                .frame(width: 840, height: 840)
                .offset(y: 60)

            // ── "D" lettermark ──────────────────────────────────────────
            Text("D")
                .font(.system(size: 580, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .offset(y: 80)

            // ── Flame ───────────────────────────────────────────────────
            FlameShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.84, blue: 0.0),   // gold tip
                            Color(red: 1.0, green: 0.55, blue: 0.0),   // amber mid
                            Color(red: 1.0, green: 0.27, blue: 0.0)    // fire base
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 180, height: 260)
                .offset(y: -220)
                .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.0).opacity(0.9), radius: 30)
        }
        .frame(width: 1024, height: 1024)
    }
}

// MARK: - Flame Shape
// Classic teardrop flame — 5 curves, bold enough to read at 29pt.

private struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()

        // Bottom-center base
        p.move(to: CGPoint(x: w * 0.5, y: h))

        // Left side — curves outward then sweeps to the tip
        p.addCurve(
            to: CGPoint(x: 0, y: h * 0.52),
            control1: CGPoint(x: w * 0.12, y: h * 0.88),
            control2: CGPoint(x: 0, y: h * 0.72)
        )
        p.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: 0,        y: h * 0.22),
            control2: CGPoint(x: w * 0.28, y: 0)
        )

        // Right side — mirror
        p.addCurve(
            to: CGPoint(x: w, y: h * 0.52),
            control1: CGPoint(x: w * 0.72, y: 0),
            control2: CGPoint(x: w,        y: h * 0.22)
        )
        p.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w,        y: h * 0.72),
            control2: CGPoint(x: w * 0.88, y: h * 0.88)
        )

        p.closeSubpath()
        return p
    }
}

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
                        .background(Color.brand)
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
                        .background(Color.brand)
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

// MARK: - Preview

#Preview("Export Icon") {
    AppIconExportView()
}
