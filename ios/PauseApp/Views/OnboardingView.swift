import SwiftUI

// Step-by-step onboarding screen matching design specifications.
struct OnboardingView: View {
    @ObservedObject var state: AppState
    @State private var step = 1
    @State private var tempPauseDuration = 10

    let allAvailableApps = ["Instagram", "TikTok", "Twitter / X", "YouTube", "Reddit", "Facebook"]

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    // Top Progress Indicators
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { idx in
                            Capsule()
                                .fill(idx <= step ? Color.indigo : Color.slate800)
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    if step == 1 {
                        // Tagline philosophy introduction
                        VStack(spacing: 28) {
                            ZStack {
                                Circle()
                                    .fill(Color.indigo.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "compass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.indigo)
                            }

                            VStack(spacing: 12) {
                                Text("You don't have to quit.\nYou just have to pause.")
                                    .font(.system(size: 28, weight: .black, design: .sans))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .lineSpacing(4)

                                Text("We are not a traditional digital block list. We are a supportive companion that helps restore the intentional space between your reflexes and actions.")
                                    .font(.system(size: 14, weight: .regular))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.slate400)
                                    .padding(.horizontal, 24)
                                    .lineSpacing(5)
                            }
                        }
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if step == 2 {
                        // Select managed apps
                        VStack(spacing: 16) {
                            VStack(spacing: 6) {
                                Text("Managed Social Networks")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Choose apps you want to pause before scrolling.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.slate400)
                            }

                            ScrollView {
                                VStack(spacing: 10) {
                                    ForEach(allAvailableApps, id: \.self) { app in
                                        Button(action: {
                                            if state.managedApps.contains(app) {
                                                state.managedApps.removeAll { $0 == app }
                                            } else {
                                                state.managedApps.append(app)
                                            }
                                        }) {
                                            HStack {
                                                Text(app)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(.white)
                                                Spacer()
                                                Image(systemName: state.managedApps.contains(app) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(state.managedApps.contains(app) ? .indigo : .slate600)
                                            }
                                            .padding()
                                            .background(state.managedApps.contains(app) ? Color.indigo.opacity(0.1) : Color.slate900)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(state.managedApps.contains(app) ? Color.indigo.opacity(0.4) : Color.slate800, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    } else if step == 3 {
                        // Set pause duration
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "timer")
                                    .font(.system(size: 32))
                                    .foregroundColor(.cyan)
                            }

                            VStack(spacing: 8) {
                                Text("Set your Pause duration")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                Text("How many seconds do you need to breathe before access is granted?")
                                    .font(.system(size: 13))
                                    .foregroundColor(.slate400)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach([5, 10, 15, 30], id: \.self) { sec in
                                    Button(action: {
                                        tempPauseDuration = sec
                                        state.pauseDuration = sec
                                    }) {
                                        Text("\(sec) Seconds")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(tempPauseDuration == sec ? .indigo : .slate300)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(tempPauseDuration == sec ? Color.indigo.opacity(0.15) : Color.slate900)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(tempPauseDuration == sec ? Color.indigo : Color.slate800, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)

                            Text("Recommended minimum pause: 10 seconds")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                        }
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    }

                    Spacer()

                    // Core Button
                    Button(action: {
                        withAnimation {
                            if step < 3 {
                                step += 1
                            } else {
                                state.isOnboarded = true
                                state.logAction(appName: "Pause App", action: "Completed Welcome Onboarding", result: "Active")
                            }
                        }
                    }) {
                        HStack {
                            Text(step == 3 ? "Ready to Try" : "Continue")
                            Image(systemName: step == 3 ? "checkmark" : "arrow.right")
                        }
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.indigo, Color.cyan]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                        .shadow(color: Color.indigo.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(24)
            )
    }
}

// Main/Home View mapping current daily scroll statistics
struct MainView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?
    @Binding var currentTab: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Top header state
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.emerald)
                            .frame(width: 8, height: 8)
                        Text("Pause Companion Active")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.slate400)
                            .textCase(.uppercase)
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView(state: state)) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundColor(.slate400)
                    }
                }
                .padding(.horizontal, 4)

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
                        .foregroundColor(.indigo)
                }
                .padding(.vertical, 16)

                // Stat Cards Grid
                HStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .frame(width: 36, height: 36)
                            .background(Color.orange.opacity(0.1))
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
                    .background(Color.slate900)
                    .cornerRadius(14)

                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundColor(.cyan)
                            .frame(width: 36, height: 36)
                            .background(Color.cyan.opacity(0.1))
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
                    .background(Color.slate900)
                    .cornerRadius(14)
                }

                // App Simulator launching trigger buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("App Trigger Simulators")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.slate300)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(state.managedApps, id: \.self) { app in
                            Button(action: {
                                activeOverlayApp = app
                            }) {
                                HStack {
                                    Image(systemName: "iphone.badge.play")
                                        .foregroundColor(.indigo)
                                        .font(.system(size: 12))
                                    Text(app)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.slate900)
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
                            .foregroundColor(.amber)
                        Text("SaaS Mindset Playbook")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.amber)
                    }
                    Text("Remember, Pause isn't trying to completely stop your scroll. We sell awareness. It's okay to open social feeds, as long as you make it a conscious choice.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.slate400)
                        .lineSpacing(4)
                }
                .padding(14)
                .background(Color.indigo.opacity(0.08))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(16)
        }
    }
}
