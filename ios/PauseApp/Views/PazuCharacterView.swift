import SwiftUI

// Pazu the Clumsy Zen Red Panda character view
struct PazuCharacterView: View {
    @ObservedObject var state: AppState
    @State private var bounceOffset: CGFloat = 0.0
    @State private var tailAngle: Double = 0.0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background Zen Garden Pond Circle
                Circle()
                    .fill(Color.charcoalLight.opacity(0.6))
                    .frame(width: 160, height: 160)
                    .overlay(
                        Circle()
                            .stroke(Color.rawBrass.opacity(0.15), lineWidth: 1)
                    )

                // Orbiting Koi Fish Indicator
                Circle()
                    .fill(getKoiColor())
                    .frame(width: 12, height: 8)
                    .offset(x: 70)
                    .rotationEffect(.degrees(tailAngle * 10))

                // Pazu Character Stack
                VStack(spacing: 2) {
                    ZStack {
                        // Hat Cosmetic
                        if state.pazuHat == "Leaf Crown" {
                            Text("👑🍃")
                                .font(.system(size: 14))
                                .offset(y: -22)
                        } else if state.pazuHat == "Straw Hat" {
                            Text("👒")
                                .font(.system(size: 18))
                                .offset(y: -22)
                        } else if state.pazuHat == "Wizard Hat" {
                            Text("🧙")
                                .font(.system(size: 18))
                                .offset(y: -22)
                        }

                        // Glasses Cosmetic
                        if state.pazuGlasses == "Round Glasses" {
                            Text("👓")
                                .font(.system(size: 14))
                                .offset(y: -6)
                        } else if state.pazuGlasses == "Sunglasses" {
                            Text("🕶️")
                                .font(.system(size: 14))
                                .offset(y: -6)
                        }

                        // Main Character Face & Body State Expression
                        Text(getPazuEmoji())
                            .font(.system(size: 42))
                            .offset(y: bounceOffset)

                        // Scarf Cosmetic
                        if state.pazuScarf == "Red Scarf" {
                            Text("🧣")
                                .font(.system(size: 16))
                                .offset(y: 16)
                        }
                    }
                    .frame(height: 60)

                    Text("Pazu")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)

                    Text(getPazuActionMessage())
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.rawBrass)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
            }
            .frame(width: 170, height: 170)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                bounceOffset = -4.0
                tailAngle = 36.0
            }
        }
    }

    private func getPazuEmoji() -> String {
        switch state.currentPazuState {
        case .idle: return "🐾"
        case .happy: return "🐾✨"
        case .proud: return "🏆🐾"
        case .clumsy: return "💥🐾"
        case .sleeping: return "💤🐾"
        case .curious: return "🧐🐾"
        case .excited: return "🎉🐾"
        case .gentleDisappointment: return "🥺🐾"
        case .meditating: return "🧘🐾"
        case .playing: return "🍃🐾"
        case .eating: return "🎋🐾"
        case .greeting: return "👋🐾"
        case .watching: return "👀🐾"
        }
    }

    private func getPazuActionMessage() -> String {
        switch state.currentPazuState {
        case .idle: return "Pazu is resting peacefully in the garden."
        case .happy: return "\"I'm happy to see you trying!\""
        case .proud: return "Proud of your \(state.streak)-day streak!"
        case .clumsy: return "Tripped over its tail! \"Eep!\" (5% clumsy chance)"
        case .sleeping: return "Curled up asleep under the tree..."
        case .curious: return "Curiously exploring the garden..."
        case .excited: return "Bouncing with excitement!"
        case .gentleDisappointment: return "Missed you, but ready when you are."
        case .meditating: return "Meditating peacefully..."
        case .playing: return "Chasing falling cherry blossom leaves!"
        case .eating: return "Munching on fresh bamboo!"
        case .greeting: return "Waving happily at you!"
        case .watching: return "Observing your mindful session..."
        }
    }

    private func getKoiColor() -> Color {
        switch state.koiColor {
        case "Orange": return Color.orange
        case "White": return Color.white
        case "Black": return Color.black
        case "Gold": return Color.rawBrass
        default: return Color.orange
        }
    }
}
