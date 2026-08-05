import SwiftUI

// Full-screen user intervention overlays, including Breathing countdown and Intention prompting.
struct PauseGateView: View {
    let appName: String
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    @State private var timeRemaining: Int = 10
    @State private var breathingScale: CGFloat = 0.9
    @State private var timerActive = false
    @State private var showsFeedSimulator = false

    var body: some View {
        ZStack {
            ZColor.background
                .ignoresSafeArea()

            if showsFeedSimulator {
                MockFeedView(appName: appName, state: state, activeOverlayApp: $activeOverlayApp)
            } else {
                VStack(spacing: 24) {
                    Spacer()

                    VStack(spacing: 8) {
                        Text("\(appName.uppercased()) IS PAUSED")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.slate500)
                            .tracking(2)

                        Text("\"Is this a conscious choice?\"")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Breathing ring animation
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                                .scaleEffect(breathingScale * 1.3)
                                .opacity(2.0 - Double(breathingScale))

                            Circle()
                                .fill(Color.indigo.opacity(0.08))
                                .frame(width: 140, height: 140)
                                .scaleEffect(breathingScale)

                            VStack(spacing: 4) {
                                Text("BREATHE")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.indigo)
                                    .tracking(1)

                                Text("\(timeRemaining)s")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(width: 160, height: 160)

                        Text("Inhale... Exhale...")
                            .font(.system(size: 13))
                            .italic()
                            .foregroundColor(.slate400)
                    }

                    Spacer()

                    VStack(spacing: 12) {
                        // Continue to Feed Button
                        Button(action: {
                            state.logAction(appName: appName, action: "Gate Unlocked", result: "Continued (15 min feed)")
                            showsFeedSimulator = true
                        }) {
                            HStack {
                                Text("Continue to Feed")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(timeRemaining > 0 ? Color.slate800 : Color.indigo)
                            .cornerRadius(12)
                        }
                        .disabled(timeRemaining > 0)

                        // Exit Button
                        Button(action: {
                            state.nudgesResisted += 1
                            state.logAction(appName: appName, action: "Gate Dismissed", result: "Resisted / Closed")
                            activeOverlayApp = nil
                        }) {
                            HStack {
                                Text("Close App / Walk Away")
                                Image(systemName: "xmark")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.slate300)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.slate900)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.slate800, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
            }
        }
        .onAppear {
            timeRemaining = state.pauseDuration
            timerActive = true
            startBreathingAnimation()

            // Countdown loop
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer.invalidate()
                }
            }
        }
    }

    private func startBreathingAnimation() {
        withAnimation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.15
        }
    }
}

// Optional pre-pause intention checklist view
struct IntentionPromptView: View {
    let appName: String
    let onSubmit: (String) -> Void

    let choices = ["Relax / unwind", "Connect with friends", "Kill time / bored", "Work / research", "Just checking"]

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("INTENTION PROMPT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.indigo)
                            .tracking(1.5)

                        Text("What are you here for?")
                            .font(.system(size: 24, weight: .black))
                            .foregroundColor(.white)

                        Text("Acknowledge your goal for opening \(appName) to reduce mindless scroll habits.")
                            .font(.system(size: 13))
                            .foregroundColor(.slate400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }

                    VStack(spacing: 12) {
                        ForEach(choices, id: \.self) { choice in
                            Button(action: {
                                onSubmit(choice)
                            }) {
                                HStack {
                                    Text(choice)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11))
                                        .foregroundColor(.slate600)
                                }
                                .padding()
                                .background(Color.slate900)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.slate800, lineWidth: 1)
                                )
                            }
                        }
                    }

                    Spacer()
                    Text("Stored locally in your privacy-first Scrollytics trend logs.")
                        .font(.system(size: 11))
                        .foregroundColor(.slate500)
                }
                .padding(24)
            )
    }
}

// After Scroll reflection card questionnaire
struct CheckInView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 28) {
                    Spacer()

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.indigo.opacity(0.1))
                                .frame(width: 60, height: 60)
                            Image(systemName: "smile")
                                .font(.system(size: 24))
                                .foregroundColor(.indigo)
                        }

                        Text("After-Scroll Reflection")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("Breathe. Take a moment to reflect on your 15-minute scrolling session.")
                            .font(.system(size: 13))
                            .foregroundColor(.slate400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    VStack(spacing: 16) {
                        Text("\"Was that time well spent?\"")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.slate200)

                        HStack(spacing: 12) {
                            Button(action: { submitReflection("Yes, I got what I needed") }) {
                                VStack(spacing: 8) {
                                    Text("😊")
                                        .font(.system(size: 28))
                                    Text("Yes")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.slate300)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.slate900)
                                .cornerRadius(12)
                            }

                            Button(action: { submitReflection("Not sure") }) {
                                VStack(spacing: 8) {
                                    Text("😐")
                                        .font(.system(size: 28))
                                    Text("Not Sure")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.slate300)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.slate900)
                                .cornerRadius(12)
                            }

                            Button(action: { submitReflection("No, I got lost") }) {
                                VStack(spacing: 8) {
                                    Text("😞")
                                        .font(.system(size: 28))
                                    Text("No, Lost")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.slate300)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.slate900)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.slate900.opacity(0.4))
                    .cornerRadius(16)

                    Spacer()

                    Text("Self-reflection increases mindfulness and naturally reduces impulse triggers over time.")
                        .font(.system(size: 11))
                        .foregroundColor(.slate500)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(24)
            )
    }

    private func submitReflection(_ rating: String) {
        state.logAction(appName: "Reflection Log", action: "After-scroll reflection check-in", result: rating)
        state.dailyScrollMinutes += 15
        activeOverlayApp = nil
    }
}

// 15-minute mock social feed session view
struct MockFeedView: View {
    let appName: String
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    @State private var timeRemaining = 15 * 60
    @State private var showCheckIn = false

    var body: some View {
        if showCheckIn {
            CheckInView(state: state, activeOverlayApp: $activeOverlayApp)
        } else {
            VStack(spacing: 0) {
                // Header bar
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.indigo)
                            .frame(width: 6, height: 6)
                        Text("\(appName) FEED")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                        Text(formatTime())
                            .font(.system(.caption, design: .monospaced))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.slate900)
                    .cornerRadius(20)
                }
                .padding()
                .background(Color.slate950)

                // Infinite post simulator placeholder
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(1...3, id: \.self) { postIdx in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Circle()
                                        .fill(Color.slate800)
                                        .frame(width: 24, height: 24)
                                    Text("@user_profile_\(postIdx)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                Text("This is infinite feed scroll simulation inside the sandbox environment. Spend some time scrolling or tap below to return.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.slate300)
                                    .lineSpacing(3)
                            }
                            .padding()
                            .background(Color.slate950)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .background(Color.slate900.opacity(0.3))

                // Bottom exit bar
                Button(action: {
                    showCheckIn = true
                }) {
                    HStack {
                        Image(systemName: "door.right.hand.open")
                        Text("Stop Scrolling (Exit Feed)")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.85))
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        timer.invalidate()
                        showCheckIn = true
                    }
                }
            }
        }
    }

    private func formatTime() -> String {
        let mins = timeRemaining / 60
        let secs = timeRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
