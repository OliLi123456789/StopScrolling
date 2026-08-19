import SwiftUI

// GardenView displays Pazu the Red Panda inside the Washi Paper Zen Garden environment
struct GardenView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.terracotta)
                            .font(.system(size: 14))
                        Text("Day \(state.streak)")
                            .font(.custom("Inter", size: 15).weight(.semibold))
                            .foregroundColor(.inkBlack)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Image(systemName: getMoodSymbol())
                            .foregroundColor(.sageGreen)
                            .font(.system(size: 14))

                        Text("★ \(state.tokens)")
                            .font(.custom("JetBrainsMono", size: 15).weight(.bold))
                            .foregroundColor(.terracotta)

                        NavigationLink(destination: SettingsView(state: state)) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 16))
                                .foregroundColor(.inkMuted)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Zen Garden ZStack
                ZStack {
                    RakedSandView()
                        .frame(height: 240)
                        .padding(.horizontal, 12)

                    BambooGroveView()
                        .offset(y: -30)
                        .opacity(0.5)

                    HStack {
                        Spacer()
                        ZenTreeView()
                            .offset(x: -20, y: 10)
                        Spacer()
                        KoiPondView()
                            .offset(x: 20, y: 30)
                        Spacer()
                    }

                    PazuCharacterView(state: state)
                        .zIndex(10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.pureWhite)
                        .shadow(color: Color.paperShadow.opacity(0.6), radius: 12, x: 0, y: 8)
                )
                .padding(.horizontal, 16)

                // Primary CTA
                Button(action: {
                    activeOverlayApp = state.managedApps.first ?? "Instagram"
                }) {
                    HStack {
                        Image(systemName: "leaf.fill")
                        Text("Start Mindful Session")
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .font(.custom("Inter", size: 17).weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.terracotta)
                            .shadow(color: Color.terracotta.opacity(0.35), radius: 8, x: 0, y: 4)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
            .padding(.bottom, 20)
        }
        .background(Color.washiPaper)
    }

    private func getMoodSymbol() -> String {
        switch state.currentPazuState {
        case .happy, .proud, .excited: return "sparkles"
        case .sleeping: return "moon.fill"
        case .meditating: return "leaf.fill"
        case .clumsy: return "exclamationmark.triangle"
        default: return "sun.max.fill"
        }
    }
}
