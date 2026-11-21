import SwiftUI

// MARK: - Flame Shape
// Classic teardrop flame — 5 curves, bold enough to read at 29pt.

struct FlameShape: Shape {
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
