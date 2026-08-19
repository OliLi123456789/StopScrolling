import SwiftUI

// Full-screen user intervention overlays with Washi Paper styling and zero emojis
struct PauseGateView: View {
    let appName: String
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    @State private var timeRemaining: Int = 10
    @State private var breathingScale: CGFloat = 0.95
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
                        Text("\(appName.uppercased()) PAUSED")
                            .font(.custom("Inter", size: 11).weight(.bold))
                            .foregroundColor(.inkMuted)
                            .tracking(2)

                        Text("\"What brings you here?\"")
                            .font(.custom("Inter", size: 22).weight(.bold))
                            .foregroundColor(.inkBlack)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer()

                    // Unified Layout: Intent selector chips
                    VStack(spacing: 12) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(intentChoices, id: \.self) { choice in
                                Button(action: {
                                    if selectedIntent == choice {
                                        selectedIntent = nil
                                    } else {
                                        selectedIntent = choice
                                    }
                                }) {
                                    Text(choice)
                                        .font(.custom("Inter", size: 12).weight(.bold))
                                        .foregroundColor(selectedIntent == choice ? .terracotta : .inkBlack)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedIntent == choice ? Color.terracotta.opacity(0.12) : Color.pureWhite)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedIntent == choice ? Color.terracotta : Color.paperBorder, lineWidth: 1)
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
                            state.tokens += 1
                            state.logAction(appName: appName, action: "Gate Unlocked (touch)", result: "Intent: \(selectedIntent ?? "None") (+1 Token)")
                            withAnimation {
                                showsFeedSimulator = true
                            }
                        }) {
                            HStack {
                                Text("YES, LET ME IN")
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            .font(.custom("Inter", size: 14).weight(.bold))
                            .foregroundColor(.white)
                            .tracking(1.5)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(Color.terracotta)
                                    .shadow(color: Color.terracotta.opacity(0.35), radius: 8, x: 0, y: 4)
                            )
                        }

                        // Hardware Bypass Double-Tap simulation link
                        Button(action: {
                            state.tokens += 1
                            state.logAction(appName: appName, action: "Gate Unlocked (hardware)", result: "Bypassed via side button (+1 Token)")
                            withAnimation {
                                showsFeedSimulator = true
                            }
                        }) {
                            Text("skip this gate by double-tapping side button")
                                .font(.custom("Inter", size: 10).weight(.medium))
                                .foregroundColor(.inkMuted)
                                .underline()
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.vertical, 24)
            }
        }
    }
}

// Optional pre-pause intention prompt view
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
                            .font(.custom("Inter", size: 10).weight(.bold))
                            .foregroundColor(.terracotta)
                            .tracking(1.5)

                        Text("What are you here for?")
                            .font(.custom("Inter", size: 24).weight(.black))
                            .foregroundColor(.inkBlack)

                        Text("Acknowledge your goal for opening \(appName) to reduce mindless scroll habits.")
                            .font(.custom("Inter", size: 13))
                            .foregroundColor(.inkMuted)
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
                                        .font(.custom("Inter", size: 14).weight(.semibold))
                                        .foregroundColor(.inkBlack)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11))
                                        .foregroundColor(.inkMuted)
                                }
                                .padding()
                                .background(Color.pureWhite)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.paperBorder, lineWidth: 1)
                                )
                            }
                        }
                    }

                    Spacer()
                    Text("Stored locally in your privacy-first Scrollytics trend logs.")
                        .font(.custom("Inter", size: 11))
                        .foregroundColor(.inkMuted)
                }
                .padding(24)
            )
    }
}

// After Scroll reflection card questionnaire with Ghost Check-In & Symbol Ratings
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
                                .fill(Color.terracotta.opacity(0.1))
                                .frame(width: 60, height: 60)
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.terracotta)
                        }

                        Text("After-Scroll Reflection")
                            .font(.custom("Inter", size: 22).weight(.bold))
                            .foregroundColor(.inkBlack)

                        Text("Take a moment to reflect on your 15-minute scrolling session.")
                            .font(.custom("Inter", size: 13))
                            .foregroundColor(.inkMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        if isAutoTriggered {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 11))
                                Text("GHOST CHECK-IN: \(12 - ghostSeconds)S LEFT")
                                    .font(.custom("Inter", size: 10).weight(.bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.terracotta)
                            .background(Color.terracotta.opacity(0.1))
                            .cornerRadius(20)
                            .padding(.top, 4)
                        }
                    }

                    // Symbol-based Rating Buttons: [Circle (Positive)], [Dash (Neutral)], [Cross (Negative)]
                    VStack(spacing: 16) {
                        Text("\"Was that time well spent?\"")
                            .font(.custom("Inter", size: 15).weight(.semibold))
                            .foregroundColor(.inkBlack)

                        HStack(spacing: 12) {
                            Button(action: { submitReflection("Positive") }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "circle")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.sageGreen)
                                    Text("Positive")
                                        .font(.custom("Inter", size: 11).weight(.semibold))
                                        .foregroundColor(.inkBlack)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.pureWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.sageGreen.opacity(0.4), lineWidth: 1)
                                )
                            }

                            Button(action: { submitReflection("Neutral") }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "minus")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.inkMuted)
                                    Text("Neutral")
                                        .font(.custom("Inter", size: 11).weight(.semibold))
                                        .foregroundColor(.inkBlack)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.pureWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.paperBorder, lineWidth: 1)
                                )
                            }

                            Button(action: { submitReflection("Negative") }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.terracotta)
                                    Text("Negative")
                                        .font(.custom("Inter", size: 11).weight(.semibold))
                                        .foregroundColor(.inkBlack)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.pureWhite)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.terracotta.opacity(0.4), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.pureWhite)
                    .cornerRadius(16)
                    .shadow(color: Color.paperShadow.opacity(0.5), radius: 8, x: 0, y: 4)

                    Spacer()

                    Text("Reflection is stored anonymously in your Scrollytics Dashboard database.")
                        .font(.custom("Inter", size: 11))
                        .foregroundColor(.inkMuted)
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

                        if ghostSeconds == 9 { // 3 seconds remaining
                            triggerDoubleHapticWarning()
                            state.logAction(appName: "Ghost Warning", action: "3s remaining", result: "Double haptic triggered")
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
        state.logAction(appName: "Ghost Auto-Logged", action: "12s elapsed", result: "Auto-logged Neutral [Dash]")
        state.dailyScrollMinutes += 15
        activeOverlayApp = nil
    }

    private func submitReflection(_ rating: String) {
        timer?.invalidate()
        state.checkedInCount += 1
        state.tokens += 3
        state.logAction(appName: "Reflection Log", action: "After-scroll reflection check-in", result: "Rated: \(rating) (+3 Tokens)")
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
                            .fill(Color.terracotta)
                            .frame(width: 6, height: 6)
                        Text("\(appName.uppercased()) FEED")
                            .font(.custom("Inter", size: 11).weight(.bold))
                            .foregroundColor(.inkBlack)
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
                    .background(Color.pureWhite)
                    .cornerRadius(20)
                }
                .padding()
                .background(Color.washiPaper)

                // Infinite post simulator placeholder
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Circle()
                                    .fill(Color.paperBorder)
                                    .frame(width: 24, height: 24)
                                Text("@doomscroller_anon")
                                    .font(.custom("Inter", size: 11).weight(.bold))
                                    .foregroundColor(.inkBlack)
                                Spacer()
                            }
                            Text("Just scrolling... nothing real here. Pause is keeping time of my session in the background.")
                                .font(.custom("Inter", size: 12))
                                .foregroundColor(.inkBlack)
                                .lineSpacing(3)
                        }
                        .padding()
                        .background(Color.pureWhite)
                        .cornerRadius(12)

                        // Live Activity Alert Card
                        VStack(spacing: 12) {
                            HStack {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.sageGreen)
                                        .frame(width: 8, height: 8)
                                    Text("15 MIN LIMIT")
                                        .font(.custom("Inter", size: 10).weight(.bold))
                                        .foregroundColor(.sageGreen)
                                }
                                Spacer()
                                Text("Live Activity")
                                    .font(.custom("Inter", size: 10).weight(.bold))
                                    .foregroundColor(.inkBlack)
                            }

                            Text("\"Time's up. Was it worth it?\"")
                                .font(.custom("Inter", size: 13).weight(.bold))
                                .foregroundColor(.inkBlack)

                            HStack(spacing: 8) {
                                Button(action: { triggerQuickCheckIn("Positive") }) {
                                    HStack {
                                        Image(systemName: "circle")
                                        Text("Positive")
                                    }
                                    .font(.custom("Inter", size: 11).weight(.semibold))
                                    .foregroundColor(.sageGreen)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.washiPaper)
                                    .cornerRadius(8)
                                }
                                Button(action: { triggerQuickCheckIn("Neutral") }) {
                                    HStack {
                                        Image(systemName: "minus")
                                        Text("Neutral")
                                    }
                                    .font(.custom("Inter", size: 11).weight(.semibold))
                                    .foregroundColor(.inkMuted)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.washiPaper)
                                    .cornerRadius(8)
                                }
                                Button(action: { triggerQuickCheckIn("Negative") }) {
                                    HStack {
                                        Image(systemName: "xmark")
                                        Text("Negative")
                                    }
                                    .font(.custom("Inter", size: 11).weight(.semibold))
                                    .foregroundColor(.terracotta)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.washiPaper)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        .background(Color.pureWhite)
                        .cornerRadius(16)
                        .shadow(color: Color.paperShadow, radius: 6, x: 0, y: 3)
                    }
                    .padding()
                }
                .background(Color.washiPaper)

                // Bottom exit bar
                Button(action: {
                    autoCheckIn = false
                    withAnimation {
                        showCheckIn = true
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Stop Scrolling (Exit Feed)")
                    }
                    .font(.custom("Inter", size: 13).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.terracotta)
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
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
        state.logAction(appName: "Reflection Log", action: "Island reflection check-in", result: "Rated: \(rating) (+3 Tokens)")
        state.dailyScrollMinutes += 15
        activeOverlayApp = nil
    }

    private func formatTime() -> String {
        let mins = max(0, timeRemaining / 60)
        let secs = max(0, timeRemaining % 60)
        return String(format: "%02d:%02d", mins, secs)
    }
}
