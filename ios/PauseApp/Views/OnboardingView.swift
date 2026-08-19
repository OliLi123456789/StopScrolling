import SwiftUI

// Step-by-step onboarding screen matching Washi Paper Minimalism specifications
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
                                .fill(idx <= step ? Color.terracotta : Color.paperBorder)
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
                                    .fill(Color.terracotta.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                Image(systemName: "compass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.terracotta)
                            }

                            VStack(spacing: 12) {
                                Text("You don't have to quit.\nYou just have to pause.")
                                    .font(.custom("Inter", size: 28).weight(.black))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.inkBlack)
                                    .lineSpacing(4)

                                Text("Meet Pazu the Red Panda. Pause is a gentle companion that restores the intentional space between your reflexes and actions.")
                                    .font(.custom("Inter", size: 14))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.inkMuted)
                                    .padding(.horizontal, 24)
                                    .lineSpacing(5)
                            }
                        }
                    } else if step == 2 {
                        // Select managed apps
                        VStack(spacing: 16) {
                            VStack(spacing: 6) {
                                Text("Managed Social Networks")
                                    .font(.custom("Inter", size: 22).weight(.bold))
                                    .foregroundColor(.inkBlack)
                                Text("Choose apps you want to pause before scrolling.")
                                    .font(.custom("Inter", size: 13))
                                    .foregroundColor(.inkMuted)
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
                                                    .font(.custom("Inter", size: 14).weight(.semibold))
                                                    .foregroundColor(.inkBlack)
                                                Spacer()
                                                Image(systemName: state.managedApps.contains(app) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(state.managedApps.contains(app) ? .terracotta : .inkMuted)
                                            }
                                            .padding()
                                            .background(Color.pureWhite)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(state.managedApps.contains(app) ? Color.terracotta : Color.paperBorder, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.top, 10)
                            }
                        }
                    } else if step == 3 {
                        // Set pause duration
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.terracotta.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "timer")
                                    .font(.system(size: 32))
                                    .foregroundColor(.terracotta)
                            }

                            VStack(spacing: 8) {
                                Text("Set your Pause duration")
                                    .font(.custom("Inter", size: 22).weight(.bold))
                                    .foregroundColor(.inkBlack)
                                Text("How many seconds do you need to breathe before access is granted?")
                                    .font(.custom("Inter", size: 13))
                                    .foregroundColor(.inkMuted)
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
                                            .font(.custom("Inter", size: 14).weight(.bold))
                                            .foregroundColor(tempPauseDuration == sec ? .terracotta : .inkBlack)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(tempPauseDuration == sec ? Color.terracotta.opacity(0.15) : Color.pureWhite)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(tempPauseDuration == sec ? Color.terracotta : Color.paperBorder, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    Spacer()

                    // Core Button
                    Button(action: {
                        withAnimation {
                            if step < 3 {
                                step += 1
                            } else {
                                state.isOnboarded = true
                                state.logAction(appName: "Pause App", action: "Started Journey", result: "Active")
                            }
                        }
                    }) {
                        HStack {
                            Text(step == 3 ? "Start My Journey" : "Continue")
                            Image(systemName: step == 3 ? "sparkles" : "arrow.right")
                        }
                        .font(.custom("Inter", size: 16).weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(Color.terracotta)
                                .shadow(color: Color.terracotta.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(24)
            )
    }
}
