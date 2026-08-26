import SwiftUI

// PazuAppIconView displays a Shoulders-Up 32-bit pixel art portrait of Pazu the Red Panda
struct PazuAppIconView: View {
    @ObservedObject var state: AppState
    var iconSize: CGFloat = 60

    private let gridSize = 32

    var body: some View {
        ZStack {
            // App Icon Squircle Background
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

            // Shoulders-Up 32-bit Canvas
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

                // Shoulders / Upper Chest
                drawRect(x: 8, y: 22, w: 16, h: 10, color: orange)
                drawRect(x: 13, y: 22, w: 6, h: 8, color: cream)

                // Ears
                drawRect(x: 7, y: 5, w: 5, h: 6, color: orange)
                drawRect(x: 8, y: 6, w: 3, h: 4, color: cream)
                drawRect(x: 20, y: 5, w: 5, h: 6, color: orange)
                drawRect(x: 21, y: 6, w: 3, h: 4, color: cream)

                // Head
                drawRect(x: 8, y: 10, w: 16, h: 13, color: orange)

                // Cream Muzzle & Cheeks
                drawRect(x: 11, y: 16, w: 10, h: 6, color: cream)
                drawRect(x: 9, y: 17, w: 14, h: 4, color: cream)

                // Nose
                drawRect(x: 15, y: 16, w: 2, h: 2, color: ink)

                // Eyes (Vector state)
                if state.currentPazuState == .happy || state.currentPazuState == .proud {
                    drawPixel(x: 11, y: 14, color: ink)
                    drawPixel(x: 12, y: 13, color: ink)
                    drawPixel(x: 13, y: 14, color: ink)
                    drawPixel(x: 18, y: 14, color: ink)
                    drawPixel(x: 19, y: 13, color: ink)
                    drawPixel(x: 20, y: 14, color: ink)
                } else if state.currentPazuState == .sleeping {
                    drawRect(x: 11, y: 14, w: 3, h: 1, color: ink)
                    drawRect(x: 18, y: 14, w: 3, h: 1, color: ink)
                } else {
                    drawRect(x: 11, y: 13, w: 3, h: 3, color: ink)
                    drawRect(x: 18, y: 13, w: 3, h: 3, color: ink)
                    drawPixel(x: 12, y: 13, color: Color.pureWhite)
                    drawPixel(x: 19, y: 13, color: Color.pureWhite)
                }

                // EQUIPPED ACCESSORIES IN APP ICON
                // Scarf
                if !state.pazuScarf.isEmpty && state.pazuScarf != "None" {
                    drawRect(x: 9, y: 21, w: 14, h: 3, color: terracotta)
                    drawRect(x: 18, y: 23, w: 3, h: 5, color: terracotta)
                }
                // Glasses
                if !state.pazuGlasses.isEmpty && state.pazuGlasses != "None" {
                    drawRect(x: 10, y: 12, w: 5, h: 5, color: ink)
                    drawRect(x: 11, y: 13, w: 3, h: 3, color: cream.opacity(0.8))
                    drawRect(x: 17, y: 12, w: 5, h: 5, color: ink)
                    drawRect(x: 18, y: 13, w: 3, h: 3, color: cream.opacity(0.8))
                    drawRect(x: 14, y: 13, w: 4, h: 1, color: ink)
                }
                // Hat
                if !state.pazuHat.isEmpty && state.pazuHat != "None" {
                    if state.pazuHat == "Leaf Crown" {
                        drawRect(x: 12, y: 7, w: 8, h: 3, color: sage)
                        drawPixel(x: 15, y: 6, color: sage)
                    } else {
                        drawRect(x: 6, y: 8, w: 20, h: 2, color: sage)
                        drawRect(x: 10, y: 3, w: 12, h: 5, color: sage)
                    }
                }
            }
        }
        .frame(width: iconSize, height: iconSize)
        .shadow(color: Color.paperShadow.opacity(0.6), radius: 4, x: 0, y: 2)
    }
}
