import SwiftUI

// Main/Home View mapping current daily scroll statistics
struct MainView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?
    @Binding var currentTab: Int

    @State private var koiAngle = 0.0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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

                    // Token indicator
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
                    .padding(.trailing, 8)

                    NavigationLink(destination: SettingsView(state: state)) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.slate400)
                    }
                }
                .padding(.horizontal, 4)

                // Dynamic Bonsai Pet Representation
                VStack(spacing: 12) {
                    ZStack {
                        // Swimming Koi water ring background
                        Circle()
                            .stroke(Color.rawBrass.opacity(0.08), lineWidth: 1)
                            .frame(width: 170, height: 170)

                        Circle()
                            .fill(Color.charcoalLight.opacity(0.4))
                            .frame(width: 150, height: 150)

                        // Floating Swimming Koi indicator based on selection
                        Circle()
                            .fill(getKoiColor())
                            .frame(width: 12, height: 8)
                            .offset(x: 75)
                            .rotationEffect(.degrees(koiAngle))

                        VStack(spacing: 4) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 44))
                                .foregroundColor(getBonsaiColor())

                            Text("\(state.selectedBonsaiSeason) Bonsai")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .tracking(1)

                            Text("Koi: \(state.koiColor) pond swim")
                                .font(.system(size: 9))
                                .foregroundColor(.slate500)
                        }
                    }
                    .frame(height: 180)
                    .onAppear {
                        withAnimation(Animation.linear(duration: 12.0).repeatForever(autoreverses: false)) {
                            koiAngle = 360.0
                        }
                    }
                }

                // Giant Daily score
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
                .padding(.vertical, 8)

                // Stat Cards Grid
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

                // App Simulator launching trigger buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Simulate App Open Launches")
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
                .padding(.top, 8)

                // Motivation block
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.rawBrass)
                        Text("SaaS Mindset Playbook")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.rawBrass)
                    }
                    Text("Remember, Pause isn't trying to completely stop your scroll. We sell awareness. It's okay to open social feeds, as long as you make it a conscious choice.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.slate400)
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color.rawBrass.opacity(0.08))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.rawBrass.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(16)
        }
    }

    private func getBonsaiColor() -> Color {
        switch state.selectedBonsaiSeason {
        case "Spring": return Color(red: 249/255, green: 168/255, blue: 212/255)
        case "Summer": return Color.emerald
        case "Autumn": return Color.rawBrass
        case "Winter": return Color.slate400
        default: return Color.emerald
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
