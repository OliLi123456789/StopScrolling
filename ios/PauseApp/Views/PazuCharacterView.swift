import SwiftUI

// PazuCharacterView procedurally renders Pazu the Red Panda using SwiftUI Canvas and vector shapes with ZERO emojis
struct PazuCharacterView: View {
    @ObservedObject var state: AppState
    @State private var walkCycleOffset: CGFloat = 0.0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Procedural Canvas Character
                Canvas { context, size in
                    let center = CGPoint(x: size.width / 2, y: size.height / 2 + 10)

                    // 1. TAIL (S-curve)
                    var tailPath = Path()
                    tailPath.move(to: CGPoint(x: center.x - 20, y: center.y + 10))
                    tailPath.addCurve(to: CGPoint(x: center.x - 45, y: center.y - 20),
                                      control1: CGPoint(x: center.x - 30, y: center.y + 15),
                                      control2: CGPoint(x: center.x - 50, y: center.y - 10))
                    tailPath.addCurve(to: CGPoint(x: center.x - 20, y: center.y + 10),
                                      control1: CGPoint(x: center.x - 30, y: center.y - 5),
                                      control2: CGPoint(x: center.x - 20, y: center.y + 5))
                    context.fill(tailPath, with: .color(.pazuOrange))

                    // 2. BODY (Rounded Rectangle)
                    let bodyRect = CGRect(x: center.x - 25, y: center.y - 10, width: 50, height: 55)
                    let bodyPath = Path(roundedRect: bodyRect, cornerRadius: 20)
                    context.fill(bodyPath, with: .color(.pazuOrange))

                    // 3. BELLY (Cream Oval)
                    let bellyRect = CGRect(x: center.x - 16, y: center.y + 2, width: 32, height: 35)
                    let bellyPath = Path(ellipseIn: bellyRect)
                    context.fill(bellyPath, with: .color(.cream))

                    // 4. HEAD (Circle)
                    let headRect = CGRect(x: center.x - 22, y: center.y - 42, width: 44, height: 44)
                    let headPath = Path(ellipseIn: headRect)
                    context.fill(headPath, with: .color(.pazuOrange))

                    // 5. EARS
                    var leftEar = Path()
                    leftEar.move(to: CGPoint(x: center.x - 18, y: center.y - 35))
                    leftEar.addLine(to: CGPoint(x: center.x - 26, y: center.y - 52))
                    leftEar.addLine(to: CGPoint(x: center.x - 8, y: center.y - 40))
                    context.fill(leftEar, with: .color(.pazuOrange))

                    var rightEar = Path()
                    rightEar.move(to: CGPoint(x: center.x + 18, y: center.y - 35))
                    rightEar.addLine(to: CGPoint(x: center.x + 26, y: center.y - 52))
                    rightEar.addLine(to: CGPoint(x: center.x + 8, y: center.y - 40))
                    context.fill(rightEar, with: .color(.pazuOrange))

                    // 6. FACE MASK (Cream Muzzle)
                    let muzzleRect = CGRect(x: center.x - 12, y: center.y - 24, width: 24, height: 18)
                    context.fill(Path(ellipseIn: muzzleRect), with: .color(.cream))

                    // 7. EYES & EXPRESSIONS (State-driven vector shapes)
                    if state.currentPazuState == .happy || state.currentPazuState == .proud {
                        var eyePath = Path()
                        eyePath.move(to: CGPoint(x: center.x - 12, y: center.y - 28))
                        eyePath.addQuadCurve(to: CGPoint(x: center.x - 6, y: center.y - 28), control: CGPoint(x: center.x - 9, y: center.y - 32))
                        eyePath.move(to: CGPoint(x: center.x + 6, y: center.y - 28))
                        eyePath.addQuadCurve(to: CGPoint(x: center.x + 12, y: center.y - 28), control: CGPoint(x: center.x + 9, y: center.y - 32))
                        context.stroke(eyePath, with: .color(.inkBlack), lineWidth: 2)
                    } else if state.currentPazuState == .sleeping {
                        var eyePath = Path()
                        eyePath.move(to: CGPoint(x: center.x - 12, y: center.y - 26))
                        eyePath.addLine(to: CGPoint(x: center.x - 6, y: center.y - 26))
                        eyePath.move(to: CGPoint(x: center.x + 6, y: center.y - 26))
                        eyePath.addLine(to: CGPoint(x: center.x + 12, y: center.y - 26))
                        context.stroke(eyePath, with: .color(.inkBlack), lineWidth: 2)
                    } else {
                        let leftEye = CGRect(x: center.x - 11, y: center.y - 30, width: 5, height: 5)
                        let rightEye = CGRect(x: center.x + 6, y: center.y - 30, width: 5, height: 5)
                        context.fill(Path(ellipseIn: leftEye), with: .color(.inkBlack))
                        context.fill(Path(ellipseIn: rightEye), with: .color(.inkBlack))
                    }

                    // 8. NOSE
                    let noseRect = CGRect(x: center.x - 3, y: center.y - 19, width: 6, height: 4)
                    context.fill(Path(ellipseIn: noseRect), with: .color(.inkBlack))

                    // 8b. EQUIPPED COSMETICS (Scarf, Glasses, Hat)
                    if let scarf = state.pazuScarf, !scarf.isEmpty {
                        let scarfRect = CGRect(x: center.x - 20, y: center.y - 3, width: 40, height: 10)
                        context.fill(Path(roundedRect: scarfRect, cornerRadius: 4), with: .color(.terracotta))
                    }
                    if let glasses = state.pazuGlasses, !glasses.isEmpty {
                        var glassesPath = Path()
                        glassesPath.addEllipse(in: CGRect(x: center.x - 14, y: center.y - 32, width: 10, height: 10))
                        glassesPath.addEllipse(in: CGRect(x: center.x + 4, y: center.y - 32, width: 10, height: 10))
                        glassesPath.move(to: CGPoint(x: center.x - 4, y: center.y - 27))
                        glassesPath.addLine(to: CGPoint(x: center.x + 4, y: center.y - 27))
                        context.stroke(glassesPath, with: .color(.inkBlack), lineWidth: 1.5)
                    }
                    if let hat = state.pazuHat, !hat.isEmpty {
                        var hatPath = Path()
                        hatPath.move(to: CGPoint(x: center.x - 22, y: center.y - 42))
                        hatPath.addLine(to: CGPoint(x: center.x, y: center.y - 62))
                        hatPath.addLine(to: CGPoint(x: center.x + 22, y: center.y - 42))
                        context.fill(hatPath, with: .color(.sageGreen))
                    }

                    // 9. LEGS
                    let leg1 = Path(ellipseIn: CGRect(x: center.x - 18, y: center.y + 40, width: 12, height: 8))
                    let leg2 = Path(ellipseIn: CGRect(x: center.x + 6, y: center.y + 40, width: 12, height: 8))
                    context.fill(leg1, with: .color(.pazuOrange))
                    context.fill(leg2, with: .color(.pazuOrange))
                }
                .frame(width: 160, height: 160)
            }

            Text("Pazu the Red Panda")
                .font(.custom("Inter", size: 13).weight(.bold))
                .foregroundColor(.inkBlack)

            Text(getPazuActionText())
                .font(.custom("Inter", size: 10))
                .foregroundColor(.terracotta)
                .multilineTextAlignment(.center)
        }
    }

    private func getPazuActionText() -> String {
        switch state.currentPazuState {
        case .idle: return "Pazu is resting peacefully in the Zen garden."
        case .happy: return "Pazu is happy to see your mindfulness!"
        case .proud: return "Pazu stands proud of your streak!"
        case .clumsy: return "Pazu tripped over its tail! Keeping trying!"
        case .sleeping: return "Pazu is sleeping peacefully..."
        case .curious: return "Pazu is curiously exploring..."
        case .excited: return "Pazu is bouncing with joy!"
        case .gentleDisappointment: return "Pazu missed you, but welcomes you back."
        case .meditating: return "Pazu is meditating..."
        case .playing: return "Pazu is playing in the leaves."
        case .eating: return "Pazu is eating bamboo."
        case .greeting: return "Pazu waves hello!"
        case .watching: return "Pazu is observing your session."
        }
    }
}
