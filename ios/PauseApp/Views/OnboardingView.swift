import SwiftUI

// Step-by-step onboarding screen matching design specifications.
struct OnboardingView: View {
    @ObservedObject var state: AppState
    @State private var step = 1
    @State private var tempPauseDuration = 10

    let allAvailableApps = ["Instagram", "TikTok", "YouTube", "Snapchat", "Reddit", "Facebook"]

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    // Top Progress Indicators
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { idx in
                            Capsule()
                                .fill(idx <= step ? Color.rawBrass : Color.slate800)
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
                                    .fill(Color.rawBrass.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "compass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.rawBrass)
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
                                                    .foregroundColor(state.managedApps.contains(app) ? .rawBrass : .slate600)
                                            }
                                            .padding()
                                            .background(state.managedApps.contains(app) ? Color.rawBrass.opacity(0.1) : Color.charcoalLight)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(state.managedApps.contains(app) ? Color.rawBrass.opacity(0.4) : Color.slate800, lineWidth: 1)
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
                                    .fill(Color.rawBrass.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "timer")
                                    .font(.system(size: 32))
                                    .foregroundColor(.rawBrass)
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
                                            .foregroundColor(tempPauseDuration == sec ? .rawBrass : .slate300)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(tempPauseDuration == sec ? Color.rawBrass.opacity(0.15) : Color.charcoalLight)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(tempPauseDuration == sec ? Color.rawBrass : Color.slate800, lineWidth: 1)
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
                        .background(LinearGradient(gradient: Gradient(colors: [Color.rawBrass, Color.rawBrass.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(14)
                        .shadow(color: Color.rawBrass.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(24)
            )
    }
}
