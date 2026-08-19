import SwiftUI

// Pazu the Clumsy Zen Red Panda character view & shoulders-up portrait
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

                // Shoulders-Up Dynamic App Icon Badge
                VStack(spacing: 2) {
                    PazuAppIconView(state: state, iconSize: 72)

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
