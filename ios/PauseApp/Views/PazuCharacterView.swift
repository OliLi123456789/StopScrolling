import SwiftUI

// PazuCharacterView procedurally renders Pazu the Red Panda in a clean 32-bit pixel art style
struct PazuCharacterView: View {
    @ObservedObject var state: AppState

    // Grid size for 32-bit pixel layout
    private let gridSize = 32

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Canvas { context, size in
                    let pixelSize = size.width / CGFloat(gridSize)

                    func drawPixel(x: Int, y: Int, color: Color) {
                        let rect = CGRect(
                            x: CGFloat(x) * pixelSize,
                            y: CGFloat(y) * pixelSize,
                            width: pixelSize,
                            height: pixelSize
                        )
                        context.fill(Path(rect), with: .color(color))
                    }

                    func drawRect(x: Int, y: Int, w: Int, h: Int, color: Color) {
                        for px in x..<(x + w) {
                            for py in y..<(y + h) {
                                drawPixel(x: px, y: py, color: color)
                            }
                        }
                    }

                    let orange = Color.pazuOrange
                    let cream = Color.cream
                    let ink = Color.inkBlack
                    let terracotta = Color.terracotta
                    let sage = Color.sageGreen

                    // 1. Tail (32-bit pixel curve left side)
                    drawRect(x: 4, y: 16, w: 5, h: 8, color: orange)
                    drawRect(x: 2, y: 18, w: 4, h: 5, color: cream)
                    drawRect(x: 3, y: 22, w: 4, h: 4, color: orange)

                    // 2. Body & Legs
                    drawRect(x: 10, y: 17, w: 12, h: 11, color: orange)
                    drawRect(x: 13, y: 19, w: 6, h: 7, color: cream) // Belly
                    drawRect(x: 10, y: 28, w: 4, h: 3, color: ink)   // Left Leg
                    drawRect(x: 18, y: 28, w: 4, h: 3, color: ink)   // Right Leg

                    // 3. Ears
                    drawRect(x: 8, y: 4, w: 4, h: 5, color: orange)
                    drawRect(x: 9, y: 5, w: 2, h: 3, color: cream)
                    drawRect(x: 20, y: 4, w: 4, h: 5, color: orange)
                    drawRect(x: 21, y: 5, w: 2, h: 3, color: cream)

                    // 4. Head
                    drawRect(x: 9, y: 8, w: 14, h: 10, color: orange)

                    // 5. White Muzzle / Cheek Fluff
                    drawRect(x: 12, y: 13, w: 8, h: 4, color: cream)
                    drawRect(x: 10, y: 14, w: 12, h: 2, color: cream)

                    // 6. Nose
                    drawRect(x: 15, y: 13, w: 2, h: 2, color: ink)

                    // 7. Eyes & Expressions
                    if state.currentPazuState == .happy || state.currentPazuState == .proud {
                        // Happy happy curved eye pixels
                        drawPixel(x: 12, y: 11, color: ink)
                        drawPixel(x: 13, y: 10, color: ink)
                        drawPixel(x: 14, y: 11, color: ink)
                        drawPixel(x: 17, y: 11, color: ink)
                        drawPixel(x: 18, y: 10, color: ink)
                        drawPixel(x: 19, y: 11, color: ink)
                    } else if state.currentPazuState == .sleeping {
                        // Sleeping horizontal line pixels
                        drawRect(x: 12, y: 11, w: 3, h: 1, color: ink)
                        drawRect(x: 17, y: 11, w: 3, h: 1, color: ink)
                    } else {
                        // Default open eyes
                        drawRect(x: 12, y: 10, w: 2, h: 2, color: ink)
                        drawRect(x: 18, y: 10, w: 2, h: 2, color: ink)
                        drawPixel(x: 13, y: 10, color: Color.pureWhite) // pixel shine
                        drawPixel(x: 19, y: 10, color: Color.pureWhite)
                    }

                    // 8. EQUIPPED 32-BIT ACCESSORIES
                    // Scarf
                    if !state.pazuScarf.isEmpty && state.pazuScarf != "None" {
                        drawRect(x: 10, y: 16, w: 12, h: 3, color: terracotta)
                        drawRect(x: 18, y: 18, w: 3, h: 4, color: terracotta)
                    }
                    // Glasses
                    if !state.pazuGlasses.isEmpty && state.pazuGlasses != "None" {
                        drawRect(x: 11, y: 9, w: 4, h: 4, color: ink)
                        drawRect(x: 12, y: 10, w: 2, h: 2, color: cream.opacity(0.7))
                        drawRect(x: 17, y: 9, w: 4, h: 4, color: ink)
                        drawRect(x: 18, y: 10, w: 2, h: 2, color: cream.opacity(0.7))
                        drawRect(x: 14, y: 10, w: 4, h: 1, color: ink)
                    }
                    // Hat
                    if !state.pazuHat.isEmpty && state.pazuHat != "None" {
                        if state.pazuHat == "Leaf Crown" {
                            drawRect(x: 13, y: 5, w: 6, h: 3, color: sage)
                            drawPixel(x: 15, y: 4, color: sage)
                        } else {
                            drawRect(x: 8, y: 6, w: 16, h: 2, color: sage)
                            drawRect(x: 11, y: 2, w: 10, h: 4, color: sage)
                        }
                    }
                }
                .frame(width: 160, height: 160)
            }

            Text("Pazu the Red Panda (32-Bit)")
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
        case .idle: return "Pazu is resting peacefully in the 32-bit Zen garden."
        case .happy: return "Pazu is happy to see your mindfulness!"
        case .proud: return "Pazu stands proud of your streak!"
        case .clumsy: return "Pazu tripped over its pixel tail! Keep trying!"
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
