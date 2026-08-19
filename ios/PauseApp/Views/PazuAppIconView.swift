import SwiftUI

// PazuAppIconView displays a Shoulders-Up portrait of Pazu the Red Panda with equipped cosmetics and Pazu's active facial expression.
struct PazuAppIconView: View {
    @ObservedObject var state: AppState
    var iconSize: CGFloat = 60

    var body: some View {
        ZStack {
            // App Icon Squircle Background with Raw Brass / Charcoal gradient
            RoundedRectangle(cornerRadius: iconSize * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.charcoalLight, Color.charcoal]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: iconSize * 0.22, style: .continuous)
                        .stroke(Color.rawBrass.opacity(0.4), lineWidth: 1.5)
                )

            // Shoulders-Up Pazu Portrait with Active Expression & Cosmetics
            VStack(spacing: -4) {
                ZStack {
                    // Hat Cosmetic Overlay
                    if state.pazuHat == "Leaf Crown" {
                        Text("👑🍃")
                            .font(.system(size: iconSize * 0.3))
                            .offset(y: -iconSize * 0.35)
                    } else if state.pazuHat == "Straw Hat" {
                        Text("👒")
                            .font(.system(size: iconSize * 0.38))
                            .offset(y: -iconSize * 0.35)
                    } else if state.pazuHat == "Wizard Hat" {
                        Text("🧙")
                            .font(.system(size: iconSize * 0.38))
                            .offset(y: -iconSize * 0.35)
                    }

                    // Glasses Cosmetic Overlay
                    if state.pazuGlasses == "Round Glasses" {
                        Text("👓")
                            .font(.system(size: iconSize * 0.28))
                            .offset(y: -iconSize * 0.1)
                    } else if state.pazuGlasses == "Sunglasses" {
                        Text("🕶️")
                            .font(.system(size: iconSize * 0.28))
                            .offset(y: -iconSize * 0.1)
                    }

                    // Pazu Head & Shoulders Base with Active Expression
                    Text(getPazuExpressionEmoji())
                        .font(.system(size: iconSize * 0.52))

                    // Scarf Cosmetic Overlay
                    if state.pazuScarf == "Red Scarf" {
                        Text("🧣")
                            .font(.system(size: iconSize * 0.3))
                            .offset(y: iconSize * 0.22)
                    }
                }
            }
        }
        .frame(width: iconSize, height: iconSize)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    // Dynamic expression mapping for Shoulders-Up App Icon
    private func getPazuExpressionEmoji() -> String {
        switch state.currentPazuState {
        case .idle: return "😊🐾"
        case .happy: return "😁🐾"
        case .proud: return "😏🐾"
        case .clumsy: return "😵🐾"
        case .sleeping: return "😴🐾"
        case .curious: return "🧐🐾"
        case .excited: return "🤩🐾"
        case .gentleDisappointment: return "🥺🐾"
        case .meditating: return "🧘🐾"
        case .playing: return "😄🐾"
        case .eating: return "😋🐾"
        case .greeting: return "👋🐾"
        case .watching: return "👀🐾"
        }
    }
}
