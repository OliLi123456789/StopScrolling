import SwiftUI

// RakedSandView renders 32-bit pixel-art Zen garden raked sand
struct RakedSandView: View {
    private let gridSize = 32

    var body: some View {
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

            let sandBase = Color(hex: "#E8E0D5")
            let sandGroove = Color(hex: "#D5CDBF")

            drawRect(x: 0, y: 0, w: 32, h: 32, color: sandBase)

            // 32-Bit Pixel Rake Grooves
            for row in [4, 10, 16, 22, 28] {
                for col in 0..<32 {
                    if (col + row) % 2 == 0 {
                        drawPixel(x: col, y: row, color: sandGroove)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 250)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}

// ZenTreeView renders 32-bit pixel-art trunk and blossom canopy
struct ZenTreeView: View {
    private let gridSize = 32

    var body: some View {
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

            let wood = Color(hex: "#6B4F3A")
            let pink = Color(hex: "#F5B7B1")

            // Trunk (32-bit pixel tree trunk)
            drawRect(x: 14, y: 16, w: 4, h: 16, color: wood)
            drawRect(x: 12, y: 22, w: 3, h: 10, color: wood)
            drawRect(x: 17, y: 12, w: 3, h: 8, color: wood)

            // Canopy
            drawRect(x: 6, y: 4, w: 18, h: 12, color: pink)
            drawRect(x: 4, y: 6, w: 22, h: 8, color: pink)
        }
        .frame(width: 140, height: 120)
    }
}

// KoiPondView renders 32-bit pixel-art koi pond
struct KoiPondView: View {
    private let gridSize = 32

    var body: some View {
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

            let water = Color(hex: "#68A2B9")
            let ripple = Color(hex: "#81B29A")

            drawRect(x: 4, y: 8, w: 24, h: 16, color: water)
            drawRect(x: 8, y: 12, w: 16, h: 8, color: ripple.opacity(0.8))
        }
        .frame(width: 110, height: 60)
    }
}

// BambooGroveView renders 32-bit pixel-art bamboo stalks
struct BambooGroveView: View {
    private let gridSize = 32

    var body: some View {
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

            let bamboo = Color.sageGreen

            for stalk in [4, 12, 20, 28] {
                drawRect(x: stalk, y: 0, w: 2, h: 32, color: bamboo)
                drawRect(x: stalk - 1, y: 10, w: 4, h: 1, color: bamboo)
                drawRect(x: stalk - 1, y: 22, w: 4, h: 1, color: bamboo)
            }
        }
        .frame(width: 80, height: 80)
    }
}
