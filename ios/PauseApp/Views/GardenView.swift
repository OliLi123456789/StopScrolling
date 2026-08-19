import SwiftUI

// GardenView displays Pazu the Red Panda inside the customizable Zen Garden environment
struct GardenView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Top header state
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.desaturatedGreen)
                            .frame(width: 8, height: 8)
                        Text("Pause Mode Active")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.desaturatedGreen)
                            .textCase(.uppercase)
                    }
                    Spacer()

                    // Star Token balance
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.rawBrass)
                        Text("\(state.tokens)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.charcoalLight)
                    .cornerRadius(20)

                    NavigationLink(destination: SettingsView(state: state)) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.slate400)
                    }
                }
                .padding(.horizontal, 4)

                // Zen Garden Environment with Pazu
                VStack(spacing: 12) {
                    PazuCharacterView(state: state)

                    // Garden Tree & Pond attributes summary
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "leaf")
                                .foregroundColor(.rawBrass)
                                .font(.system(size: 10))
                            Text("Tree: \(state.gardenTree)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.slate300)
                        }

                        Text("•")
                            .foregroundColor(.slate600)

                        HStack(spacing: 4) {
                            Image(systemName: "drop")
                                .foregroundColor(.cyan)
                                .font(.system(size: 10))
                            Text("Pond: \(state.gardenPond)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.slate300)
                        }
                    }
                }

                // Giant Daily Score
                VStack(spacing: 4) {
                    Text("Today's Scroll Time")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.slate500)
                        .textCase(.uppercase)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(state.dailyScrollMinutes)")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("Minutes")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.slate400)
                    }

                    Text("Mindful choices: \(state.nudgesResisted) of \(state.nudgesTriggered) trigger gates")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.rawBrass)
                }
                .padding(.vertical, 4)

                // Stats Strip
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.rawBrass)
                            .frame(width: 36, height: 36)
                            .background(Color.rawBrass.opacity(0.1))
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Streak")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                            Text("\(state.streak) Mindful Days")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.charcoalLight)
                    .cornerRadius(14)

                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundColor(.rawBrass)
                            .frame(width: 36, height: 36)
                            .background(Color.rawBrass.opacity(0.1))
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next Session")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                            Text("19:00 PM")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.charcoalLight)
                    .cornerRadius(14)
                }

                // App Launch Simulators
                VStack(alignment: .leading, spacing: 12) {
                    Text("Simulate Social App Open")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.slate300)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(state.managedApps, id: \.self) { app in
                            Button(action: {
                                activeOverlayApp = app
                            }) {
                                HStack {
                                    Image(systemName: "iphone.badge.play")
                                        .foregroundColor(.rawBrass)
                                        .font(.system(size: 12))
                                    Text(app)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.charcoalLight)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}
