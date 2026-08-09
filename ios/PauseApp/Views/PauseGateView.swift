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
    @State private var selectedIntent: String? = nil

    let intentChoices = ["Relax / unwind", "Connect w/ friends", "Kill time / bored", "Work / research"]

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
                        Text("\(appName.uppercased()) TRIGGERED")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.slate500)
                            .tracking(2)

                        Text("\"What brings you here?\"")
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Unified Layout: Intent selector chips
                    VStack(spacing: 12) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(intentChoices, id: \.self) { choice in
                                Button(action: {
                                    triggerSelectionHaptic()
                                    if selectedIntent == choice {
                                        selectedIntent = nil
                                    } else {
                                        selectedIntent = choice
                                    }
                                }) {
                                    Text(choice)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(selectedIntent == choice ? .rawBrass : .slate300)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedIntent == choice ? Color.rawBrass.opacity(0.15) : Color.charcoalLight)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedIntent == choice ? Color.rawBrass : Color.slate800, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Decisive Turbo-Tap Button
                    VStack(spacing: 16) {
                        Button(action: {
                            triggerHeavyHaptic()
                            state.tokens += 1 // award 1 token for entry
                            state.logAction(appName: appName, action: "Gate Unlocked (touch)", result: "Intent: \(selectedIntent ?? "None") (+1 Token)")
                            withAnimation {
                                showsFeedSimulator = true
                            }
                        }) {
                            HStack {
                                Text("YES, LET ME IN")
                                Image(systemName: "door.right.hand.open")
                            }
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.rawBrass)
                            .cornerRadius(14)
                            .shadow(color: Color.rawBrass.opacity(0.3), radius: 8, y: 4)
                        }

                        // Hardware Bypass Double-Tap simulation link
                        Button(action: {
                            triggerSelectionHaptic()
                            state.tokens += 1
                            state.logAction(appName: appName, action: "Gate Unlocked (hardware)", result: "Bypassed via side button (+1 Token)")
                            withAnimation {
                                showsFeedSimulator = true
                            }
                        }) {
                            Text("skip this gate by double-tapping side button")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.slate500)
                                .underline()
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
        }
    }

    private func startBreathingAnimation() {
        withAnimation(Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.15
        }
    }

    private func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    private func triggerHeavyHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

// Optional pre-pause intention checklist view
struct IntentionPromptView: View {
    let appName: String
    let onSubmit: (String) -> Void

    let choices = ["Relax / unwind", "Connect w/ friends", "Kill time / bored", "Work / research"]

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("INTENTION PROMPT")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.rawBrass)
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
                                .background(Color.charcoalLight)
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

// After Scroll reflection card questionnaire with Ghost Check-In
struct CheckInView: View {
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?
    let isAutoTriggered: Bool

    @State private var ghostSeconds = 0
    @State private var timer: Timer? = nil

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                VStack(spacing: 28) {
                    Spacer()

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.rawBrass.opacity(0.1))
                                .frame(width: 60, height: 60)
                            Image(systemName: "smile")
                                .font(.system(size: 24))
                                .foregroundColor(.rawBrass)
                        }

                        Text("After-Scroll Reflection")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text("Breathe. Take a moment to reflect on your 15-minute scrolling session.")
                            .font(.system(size: 13))
                            .foregroundColor(.slate400)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        if isAutoTriggered {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.ring")
                                    .font(.system(size: 11))
                                Text("GHOST CHECK-IN ACTIVE: \(12 - ghostSeconds)S LEFT")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.rose)
                            .background(Color.rose.opacity(0.1))
                            .cornerRadius(20)
                            .padding(.top, 4)
                        }
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
                                .background(Color.charcoalLight)
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
                                .background(Color.charcoalLight)
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
                                .background(Color.charcoalLight)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.charcoalLight.opacity(0.4))
                    .cornerRadius(16)

                    Spacer()

                    Text("Reflection is stored anonymously in your Scrollytics Dashboard database.")
                        .font(.system(size: 11))
                        .foregroundColor(.slate500)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
                .padding(24)
            )
            .onAppear {
                if isAutoTriggered {
                    state.logAction(appName: "Ghost Check-In", action: "Ghost Check-In Active", result: "12s window started")
                    ghostSeconds = 0
                    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        ghostSeconds += 1

                        if ghostSeconds == 3 {
                            triggerDoubleHapticWarning()
                            state.logAction(appName: "Ghost Warning", action: "3 seconds elapsed", result: "Double haptic triggered")
                        }

                        if ghostSeconds >= 12 {
                            timer?.invalidate()
                            autoLogGhostNeutral()
                        }
                    }
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
    }

    private func triggerDoubleHapticWarning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            generator.notificationOccurred(.warning)
        }
    }

    private func autoLogGhostNeutral() {
        state.checkedInCount += 1
        state.tokens += 1
        state.logAction(appName: "Ghost Auto-Logged", action: "12s elapsed", result: "Auto-logged Neutral 😐")
        state.dailyScrollMinutes += 15
        activeOverlayApp = nil
    }

    private func submitReflection(_ rating: String) {
        timer?.invalidate()
        state.checkedInCount += 1
        state.tokens += 3 // award 3 tokens for rating session
        state.logAction(appName: "Reflection Log", action: "After-scroll reflection check-in", result: "\(rating) (+3 Tokens)")
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
    @State private var autoCheckIn = false

    var body: some View {
        if showCheckIn {
            CheckInView(state: state, activeOverlayApp: $activeOverlayApp, isAutoTriggered: autoCheckIn)
        } else {
            VStack(spacing: 0) {
                // Header bar
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.rawBrass)
                            .frame(width: 6, height: 6)
                        Text("\(appName.uppercased()) SIM")
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
                    .background(Color.charcoalLight)
                    .cornerRadius(20)
                }
                .padding()
                .background(Color.charcoal)

                // Infinite post simulator placeholder
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Circle()
                                    .fill(Color.slate800)
                                    .frame(width: 24, height: 24)
                                Text("@doomscroller_anon")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            Text("Just scrolling... nothing real here. Just wasting seconds. But wait, Pause is keeping time of my session in the background!")
                                .font(.system(size: 12))
                                .foregroundColor(.slate300)
                                .lineSpacing(3)
                        }
                        .padding()
                        .background(Color.charcoalLight)
                        .cornerRadius(12)

                        // Interactive Dynamic Island alert overlay representation
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.desaturatedGreen)
                                        .frame(width: 8, height: 8)
                                    Text("15/15 MIN LIMIT")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.desaturatedGreen)
                                }
                                Spacer()
                                Text("Dynamic Island Alert")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            Text("\"Time's up. Was it worth it?\"")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .italic()

                            HStack(spacing: 8) {
                                Button(action: { triggerQuickCheckIn("Yes, I got what I needed") }) {
                                    Text("😊 Yes")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.charcoalLight)
                                        .cornerRadius(8)
                                }
                                Button(action: { triggerQuickCheckIn("Not sure") }) {
                                    Text("😐 Neutral")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.charcoalLight)
                                        .cornerRadius(8)
                                }
                                Button(action: { triggerQuickCheckIn("No, I got lost") }) {
                                    Text("😞 No")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.charcoalLight)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.desaturatedGreen.opacity(0.3), lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Circle()
                                        .fill(Color.slate800)
                                        .frame(width: 24, height: 24)
                                Text("@viral_feed_trend")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            Text("This is simulated infinite scrolling inside the sandbox environment.")
                                .font(.system(size: 12))
                                .foregroundColor(.slate300)
                                .lineSpacing(3)
                        }
                        .padding()
                        .background(Color.charcoalLight)
                        .cornerRadius(12)
                    }
                    .padding()
                }
                .background(Color.charcoal)

                // Bottom exit bar
                Button(action: {
                    autoCheckIn = false
                    withAnimation {
                        showCheckIn = true
                    }
                }) {
                    HStack {
                        Image(systemName: "log.out")
                        Text("Stop Scrolling (Exit Feed)")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.rose.opacity(0.85))
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    // Speed up simulation to tick down 150 seconds per second
                    if timeRemaining > 0 {
                        timeRemaining -= 150
                    } else {
                        timer.invalidate()
                        autoCheckIn = true
                        withAnimation {
                            showCheckIn = true
                        }
                    }
                }
            }
        }
    }

    private func triggerQuickCheckIn(_ rating: String) {
        state.checkedInCount += 1
        state.tokens += 3
        state.logAction(appName: "Reflection Log", action: "Island reflection check-in", result: "\(rating) (+3 Tokens)")
        state.dailyScrollMinutes += 15
        activeOverlayApp = nil
    }

    private func formatTime() -> String {
        let mins = max(0, timeRemaining / 60)
        let secs = max(0, timeRemaining % 60)
        return String(format: "%02d:%02d", mins, secs)
    }
}
