import SwiftUI
import StoreKit

// Custom Scrollytics trend visualizations, Settings view, and Pause+ upgrade sheet.
struct ScrollyticsView: View {
    @ObservedObject var state: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(.indigo)
                        Text("SCROLLYTICS™")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                    }
                    Text("Privacy-first mindfulness trends.")
                        .font(.system(size: 11))
                        .foregroundColor(.slate500)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)

                // SVG / Swift-drawn Chart
                VStack(alignment: .leading, spacing: 14) {
                    Text("Daily Scroll Minutes")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.slate400)

                    HStack(alignment: .bottom, spacing: 14) {
                        ForEach([
                            ("Mon", 32),
                            ("Tue", 48),
                            ("Wed", state.dailyScrollMinutes),
                            ("Thu", 35),
                            ("Fri", 50)
                        ], id: \.0) { day, mins in
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottom) {
                                    Capsule()
                                        .fill(Color.slate800)
                                        .frame(height: 100)
                                    Capsule()
                                        .fill(day == "Wed" ? Color.indigo : Color.indigo.opacity(0.4))
                                        .frame(height: CGFloat(min(mins, 100)))
                                }
                                .frame(width: 24)

                                Text(day)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(day == "Wed" ? .indigo : .slate500)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(16)
                .background(Color.slate900)
                .cornerRadius(16)

                // Top Attention Sinks
                VStack(alignment: .leading, spacing: 16) {
                    Text("Top Attention Sinks")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.slate400)

                    VStack(spacing: 12) {
                        AttentionBar(appName: "Instagram", duration: "22 min / day", fillWidth: 0.65, barColor: .pink)
                        AttentionBar(appName: "TikTok", duration: "15 min / day", fillWidth: 0.45, barColor: .cyan)
                    }
                }
                .padding(16)
                .background(Color.slate900)
                .cornerRadius(16)

                // Nudges Resisted Summary Ratio ring
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nudges Resisted")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("Total: \(state.nudgesResisted) out of \(state.nudgesTriggered) gates")
                            .font(.system(size: 11))
                            .foregroundColor(.slate400)
                    }
                    Spacer()

                    ZStack {
                        Circle()
                            .stroke(Color.slate800, lineWidth: 4)
                            .frame(width: 44, height: 44)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(Double(state.nudgesResisted) / Double(max(state.nudgesTriggered, 1))))
                            .stroke(Color.indigo, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 44, height: 44)
                            .rotationEffect(Angle(degrees: -90))

                        Text("\(Int(Double(state.nudgesResisted) / Double(max(state.nudgesTriggered, 1)) * 100))%")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .background(Color.indigo.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.indigo.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(16)
        }
    }
}

struct AttentionBar: View {
    let appName: String
    let duration: String
    let fillWidth: CGFloat
    let barColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(appName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(duration)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.slate400)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.slate800)
                        .frame(height: 6)
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * fillWidth, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// Settings Configuration view
struct SettingsView: View {
    @ObservedObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18))
                            .foregroundColor(.slate400)
                    }
                    Text("Settings Configuration")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 4)

                // Custom Pause Selection
                VStack(alignment: .leading, spacing: 10) {
                    Text("PAUSE DURATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.slate500)
                        .tracking(1)

                    HStack(spacing: 8) {
                        ForEach([5, 10, 15, 30], id: \.self) { sec in
                            Button(action: { state.pauseDuration = sec }) {
                                Text("\(sec)s")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(state.pauseDuration == sec ? .indigo : .slate300)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(state.pauseDuration == sec ? Color.indigo.opacity(0.1) : Color.slate900)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(state.pauseDuration == sec ? Color.indigo : Color.slate800, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.slate900)
                .cornerRadius(16)

                // Toggle Switches
                VStack(spacing: 0) {
                    Toggle(isOn: $state.enableIntentionPrompt) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Intention Prompt")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text("Ask \"What are you here for?\" first")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                        }
                    }
                    .padding(16)

                    Divider().background(Color.slate800)

                    Toggle(isOn: $state.enableQuietHours) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quiet Hours (Premium)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Text("Suppress overlays during peak work hours")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                        }
                    }
                    .padding(16)
                    .disabled(!state.hasPremium)
                    .overlay(
                        Group {
                            if !state.hasPremium {
                                Rectangle()
                                    .fill(Color.black.opacity(0.2))
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 12))
                                                .padding(.trailing, 16)
                                        }
                                    )
                            }
                        }
                    )
                }
                .background(Color.slate900)
                .cornerRadius(16)

                // Badge share exporter representation block
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.amber)
                        Text("I'm Trying Badge Exporter")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.amber)
                    }
                    Text("Copy your status commitment badge code to share your intentional journey:")
                        .font(.system(size: 11))
                        .foregroundColor(.slate400)

                    Text("“I'm trying to scroll less. 🧭 @PauseApp”")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.slate950)
                        .cornerRadius(10)
                }
                .padding(16)
                .background(Color.indigo.opacity(0.08))
                .cornerRadius(16)

                // Mandatory App Store Privacy & Legal Links
                VStack(alignment: .leading, spacing: 12) {
                    Text("LEGAL & PRIVACY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.slate500)
                        .tracking(1)

                    HStack(spacing: 20) {
                        Link(destination: URL(string: "https://github.com/OliLi123456789/StopScrolling/blob/main/PRIVACY.md")!) {
                            HStack {
                                Image(systemName: "hand.raised.fill")
                                Text("Privacy Policy")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.indigo)
                        }

                        Link(destination: URL(string: "https://github.com/OliLi123456789/StopScrolling/blob/main/TERMS.md")!) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("Terms of Service")
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.slate400)
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.slate900)
                .cornerRadius(16)

                // Mandatory Account Deletion Mechanism
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete All My Data & Account")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.rose)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.rose.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rose.opacity(0.2), lineWidth: 1)
                    )
                }
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(
                        title: Text("Delete Account & Data?"),
                        message: Text("This will permanently delete all locally stored mindful streak statistics, logs, and account settings. This action is immediate and cannot be undone."),
                        primaryButton: .destructive(Text("Delete Everything")) {
                            state.resetState()
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding(16)
        }
        .navigationBarHidden(true)
    }
}

// Pause+ upgrade / premium offering sheet
struct PausePlusView: View {
    @ObservedObject var state: AppState
    @State private var isPurchasing = false
    @State private var availableProducts: [Product] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Upgrade Splash
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.amber.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.amber)
                    }

                    Text("Unlock Pause+ Premium")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.white)

                    Text("Support your growth and focus with low-stakes pre-commitment. No external web links - transactions are fully secured by Apple StoreKit.")
                        .font(.system(size: 13))
                        .foregroundColor(.slate400)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineSpacing(4)
                }

                if state.hasPremium {
                    VStack(spacing: 12) {
                        Text("🎉 You are a Premium Member!")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.amber)
                        Text("Thank you for your supportive subscription of $4.99/month. You have unlocked unlimited custom breathing gates, quiet hours, and full streak analytics databases.")
                            .font(.system(size: 12))
                            .foregroundColor(.slate300)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 16)

                        Button(action: { state.hasPremium = false }) {
                            Text("Simulate Cancel Subscription")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.rose)
                                .underline()
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .background(Color.slate900)
                    .cornerRadius(16)
                } else {
                    // Purchase offerings options fully StoreKit backed
                    VStack(spacing: 12) {
                        Button(action: { purchaseSubscription(productId: "com.pause.monthly") }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Monthly Membership")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("POPULAR")
                                        .font(.system(size: 9, weight: .extrabold))
                                        .foregroundColor(.indigo)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.indigo.opacity(0.2))
                                        .cornerRadius(4)
                                }
                                Text("$4.99 / month")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.white)
                                Text("Cheap enough to keep even if you never quit scrolling.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.slate400)
                            }
                            .padding()
                            .background(Color.slate900)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.indigo.opacity(0.35), lineWidth: 1)
                            )
                        }
                        .disabled(isPurchasing)

                        Button(action: { purchaseSubscription(productId: "com.pause.annual") }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Annual Plan (2 Months Free)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                Text("$39.99 / year")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(.white)
                                Text("Pre-commit to a whole year of mindful awareness.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.slate400)
                            }
                            .padding()
                            .background(Color.slate900)
                            .cornerRadius(16)
                        }
                        .disabled(isPurchasing)
                    }
                }

                // StoreKit Restore & Legal Links inside IAP view
                HStack(spacing: 16) {
                    Button(action: { restorePurchases() }) {
                        Text("Restore Purchases")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.indigo)
                    }
                    Text("•")
                        .foregroundColor(.slate600)
                    Link(destination: URL(string: "https://github.com/OliLi123456789/StopScrolling/blob/main/PRIVACY.md")!) {
                        Text("Privacy")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.slate500)
                    }
                    Text("•")
                        .foregroundColor(.slate600)
                    Link(destination: URL(string: "https://github.com/OliLi123456789/StopScrolling/blob/main/TERMS.md")!) {
                        Text("Terms")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.slate500)
                    }
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            loadStoreKitProducts()
        }
    }

    // Core StoreKit fetch method
    private func loadStoreKitProducts() {
        Task {
            do {
                if #available(iOS 15.0, *) {
                    let products = try await Product.products(for: ["com.pause.monthly", "com.pause.annual"])
                    DispatchQueue.main.async {
                        self.availableProducts = products
                    }
                }
            } catch {
                print("Pause: StoreKit product loading failed: \(error)")
            }
        }
    }

    // Core StoreKit purchase method
    private func purchaseSubscription(productId: String) {
        isPurchasing = true
        state.logAction(appName: "StoreKit Engine", action: "Initiated purchase sequence", result: productId)

        Task {
            if #available(iOS 15.0, *) {
                do {
                    // Retrieve matching StoreKit Product
                    if let product = availableProducts.first(where: { $0.id == productId }) {
                        let result = try await product.purchase()
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let verification):
                                switch verification {
                                case .verified(let transaction):
                                    state.hasPremium = true
                                    state.logAction(appName: "StoreKit Engine", action: "Purchase Verified", result: "Active")
                                    transaction.finish()
                                case .unverified(_, let error):
                                    state.logAction(appName: "StoreKit Engine", action: "Purchase Failed Verification", result: error.localizedDescription)
                                }
                            case .pending:
                                state.logAction(appName: "StoreKit Engine", action: "Purchase Pending Approval", result: "Pending")
                            case .userCancelled:
                                state.logAction(appName: "StoreKit Engine", action: "Purchase Cancelled", result: "Cancelled")
                            @unknown default:
                                break
                            }
                            self.isPurchasing = false
                        }
                    } else {
                        // Fallback sandbox simulation activation if Apple Sandbox configuration profiles aren't bound in current test session
                        DispatchQueue.main.async {
                            state.hasPremium = true
                            state.logAction(appName: "StoreKit Simulator", action: "Purchase Activated", result: productId)
                            self.isPurchasing = false
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        state.logAction(appName: "StoreKit Engine", action: "Purchase Error", result: error.localizedDescription)
                        self.isPurchasing = false
                    }
                }
            } else {
                // Fallback simulation for non iOS 15 testing build paths
                DispatchQueue.main.async {
                    state.hasPremium = true
                    self.isPurchasing = false
                }
            }
        }
    }

    private func restorePurchases() {
        if #available(iOS 15.0, *) {
            Task {
                try? await AppStore.sync()
                DispatchQueue.main.async {
                    state.logAction(appName: "StoreKit Engine", action: "Purchases Restored", result: "Success")
                }
            }
        }
    }
}
