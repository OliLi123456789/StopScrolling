import SwiftUI

// MainView renders the Zen Garden Environment with Pazu the Red Panda
struct MainView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Top Bar
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
                        // Mood Symbol Indicator
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

                // MARK: - The Zen Garden (Layered Environment)
                ZStack {
                    RakedSandView()
                        .frame(height: 240)
                        .padding(.horizontal, 12)

                    // Background Bamboo
                    BambooGroveView()
                        .offset(y: -30)
                        .opacity(0.5)

                    // Midground Tree & Pond
                    HStack {
                        Spacer()
                        ZenTreeView()
                            .offset(x: -20, y: 10)
                        Spacer()
                        KoiPondView()
                            .offset(x: 20, y: 30)
                        Spacer()
                    }

                    // Foreground Procedural Pazu Red Panda
                    PazuCharacterView(state: state)
                        .zIndex(10)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.pureWhite)
                        .shadow(color: Color.paperShadow.opacity(0.6), radius: 12, x: 0, y: 8)
                )
                .padding(.horizontal, 16)

                // MARK: - Primary CTA Button
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

                // App Simulator Quick Triggers
                VStack(alignment: .leading, spacing: 12) {
                    Text("Managed Triggers")
                        .font(.custom("Inter", size: 13).weight(.bold))
                        .foregroundColor(.inkMuted)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(state.managedApps, id: \.self) { app in
                            Button(action: {
                                activeOverlayApp = app
                            }) {
                                HStack {
                                    Image(systemName: "iphone.badge.play")
                                        .foregroundColor(.terracotta)
                                        .font(.system(size: 12))
                                    Text(app)
                                        .font(.custom("Inter", size: 12).weight(.semibold))
                                        .foregroundColor(.inkBlack)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.pureWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.paperBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
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
