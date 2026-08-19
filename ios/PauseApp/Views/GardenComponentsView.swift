import SwiftUI

// RakedSandView renders Zen garden raked sand with quad curve grooves
struct RakedSandView: View {
    var body: some View {
        Canvas { context, size in
            // Base sand color (#E8E0D5)
            let sandRect = CGRect(origin: .zero, size: size)
            context.fill(Path(sandRect), with: .color(Color(hex: "#E8E0D5")))

            // Draw raked lines
            for i in 0...8 {
                let yOffset = CGFloat(i) * 25 + 10
                var linePath = Path()
                linePath.move(to: CGPoint(x: 0, y: yOffset))
                linePath.addQuadCurve(to: CGPoint(x: size.width, y: yOffset + 10),
                                      control: CGPoint(x: size.width/2, y: yOffset - 20))
                context.stroke(linePath, with: .color(Color(hex: "#D5CDBF").opacity(0.6)), lineWidth: 2)
            }

            // Concentric ripples
            for i in 1...3 {
                let radius = CGFloat(i) * 15
                let circlePath = Path(ellipseIn: CGRect(x: size.width/2 - radius, y: size.height/2 - radius, width: radius*2, height: radius*2))
                context.stroke(circlePath, with: .color(Color(hex: "#D5CDBF").opacity(0.3)), lineWidth: 1.5, dash: [4, 6])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 250)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

// ZenTreeView renders the curved trunk and cherry blossom canopy
struct ZenTreeView: View {
    var body: some View {
        ZStack {
            // Trunk
            Path { path in
                path.move(to: CGPoint(x: 50, y: 120))
                path.addCurve(to: CGPoint(x: 40, y: 40),
                              control1: CGPoint(x: 45, y: 80),
                              control2: CGPoint(x: 60, y: 60))
                path.addCurve(to: CGPoint(x: 30, y: 10),
                              control1: CGPoint(x: 30, y: 30),
                              control2: CGPoint(x: 40, y: 20))
            }
            .stroke(Color(hex: "#6B4F3A"), lineWidth: 18)

            // Soft Blossom Canopy
            ForEach(0..<5) { i in
                let x = CGFloat(i) * 12 + 15
                let y = CGFloat(i % 3) * 15 + 5
                Circle()
                    .fill(Color(hex: "#F5B7B1").opacity(0.85))
                    .frame(width: 35 + CGFloat(i * 4), height: 35 + CGFloat(i * 4))
                    .offset(x: x - 30, y: y - 30)
            }
        }
        .frame(width: 140, height: 120)
    }
}

// KoiPondView renders serene water base and animated ripple ovals
struct KoiPondView: View {
    @State private var ripplePhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Water base
            Ellipse()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "#68A2B9"), Color(hex: "#4A7C8C")]), startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 110, height: 60)

            // Ripples
            ForEach(0..<2) { i in
                Ellipse()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    .frame(width: 35 + ripplePhase * 15, height: 18 + ripplePhase * 8)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                ripplePhase = 1.0
            }
        }
    }
}

// BambooGroveView renders background bamboo stalks
struct BambooGroveView: View {
    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { _ in
                Capsule()
                    .fill(Color.sageGreen.opacity(0.4))
                    .frame(width: 6, height: 80)
            }
        }
    }
}
