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
