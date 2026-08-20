import SwiftUI

// PazuAppIconView displays a Shoulders-Up procedural Canvas portrait of Pazu the Red Panda with equipped cosmetics and zero emojis
struct PazuAppIconView: View {
    @ObservedObject var state: AppState
    var iconSize: CGFloat = 60

    var body: some View {
        ZStack {
            // App Icon Squircle Background with Washi Paper / Terracotta border
            RoundedRectangle(cornerRadius: iconSize * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.pureWhite, Color.washiPaper]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: iconSize * 0.22, style: .continuous)
                        .stroke(Color.paperBorder, lineWidth: 1.5)
                )

            // Shoulders-Up Procedural Pazu Canvas
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2 + 6)

                // Head
                let headRect = CGRect(x: center.x - 22, y: center.y - 22, width: 44, height: 44)
                context.fill(Path(ellipseIn: headRect), with: .color(.pazuOrange))

                // Ears
                var leftEar = Path()
                leftEar.move(to: CGPoint(x: center.x - 18, y: center.y - 15))
                leftEar.addLine(to: CGPoint(x: center.x - 25, y: center.y - 32))
                leftEar.addLine(to: CGPoint(x: center.x - 8, y: center.y - 20))
                context.fill(leftEar, with: .color(.pazuOrange))

                var rightEar = Path()
                rightEar.move(to: CGPoint(x: center.x + 18, y: center.y - 15))
                rightEar.addLine(to: CGPoint(x: center.x + 25, y: center.y - 32))
                rightEar.addLine(to: CGPoint(x: center.x + 8, y: center.y - 20))
                context.fill(rightEar, with: .color(.pazuOrange))

                // White Muzzle / Cheek Mask
                let muzzleRect = CGRect(x: center.x - 12, y: center.y - 4, width: 24, height: 18)
                context.fill(Path(ellipseIn: muzzleRect), with: .color(.cream))

                // Eyes (Vector expression based on state)
                if state.currentPazuState == .happy || state.currentPazuState == .proud {
                    var eyePath = Path()
                    eyePath.move(to: CGPoint(x: center.x - 12, y: center.y - 8))
                    eyePath.addQuadCurve(to: CGPoint(x: center.x - 6, y: center.y - 8), control: CGPoint(x: center.x - 9, y: center.y - 12))
                    eyePath.move(to: CGPoint(x: center.x + 6, y: center.y - 8))
                    eyePath.addQuadCurve(to: CGPoint(x: center.x + 12, y: center.y - 8), control: CGPoint(x: center.x + 9, y: center.y - 12))
                    context.stroke(eyePath, with: .color(.inkBlack), lineWidth: 2)
                } else if state.currentPazuState == .sleeping {
                    var eyePath = Path()
                    eyePath.move(to: CGPoint(x: center.x - 12, y: center.y - 8))
                    eyePath.addLine(to: CGPoint(x: center.x - 6, y: center.y - 8))
                    eyePath.move(to: CGPoint(x: center.x + 6, y: center.y - 8))
                    eyePath.addLine(to: CGPoint(x: center.x + 12, y: center.y - 8))
                    context.stroke(eyePath, with: .color(.inkBlack), lineWidth: 2)
                } else {
                    let leftEye = CGRect(x: center.x - 11, y: center.y - 10, width: 5, height: 5)
                    let rightEye = CGRect(x: center.x + 6, y: center.y - 10, width: 5, height: 5)
                    context.fill(Path(ellipseIn: leftEye), with: .color(.inkBlack))
                    context.fill(Path(ellipseIn: rightEye), with: .color(.inkBlack))
                }

                // Nose
                let noseRect = CGRect(x: center.x - 3, y: center.y + 1, width: 6, height: 4)
                context.fill(Path(ellipseIn: noseRect), with: .color(.inkBlack))

                // EQUIPPED COSMETICS (Scarf, Glasses, Hat)
                if let scarf = state.pazuScarf, !scarf.isEmpty {
                    let scarfRect = CGRect(x: center.x - 18, y: center.y + 12, width: 36, height: 8)
                    context.fill(Path(roundedRect: scarfRect, cornerRadius: 3), with: .color(.terracotta))
                }
                if let glasses = state.pazuGlasses, !glasses.isEmpty {
                    var glassesPath = Path()
                    glassesPath.addEllipse(in: CGRect(x: center.x - 14, y: center.y - 12, width: 10, height: 10))
                    glassesPath.addEllipse(in: CGRect(x: center.x + 4, y: center.y - 12, width: 10, height: 10))
                    glassesPath.move(to: CGPoint(x: center.x - 4, y: center.y - 7))
                    glassesPath.addLine(to: CGPoint(x: center.x + 4, y: center.y - 7))
                    context.stroke(glassesPath, with: .color(.inkBlack), lineWidth: 1.5)
                }
                if let hat = state.pazuHat, !hat.isEmpty {
                    var hatPath = Path()
                    hatPath.move(to: CGPoint(x: center.x - 20, y: center.y - 22))
                    hatPath.addLine(to: CGPoint(x: center.x, y: center.y - 38))
                    hatPath.addLine(to: CGPoint(x: center.x + 20, y: center.y - 22))
                    context.fill(hatPath, with: .color(.sageGreen))
                }
            }
        }
        .frame(width: iconSize, height: iconSize)
        .shadow(color: Color.paperShadow.opacity(0.6), radius: 4, x: 0, y: 2)
    }
}
