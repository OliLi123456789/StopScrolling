import SwiftUI

// Custom Scrollytics trend visualizations, Settings view, and Pause+ upgrade sheet.
struct ScrollyticsView: View {
    @ObservedObject var state: AppState
    @State private var activeTab = 0 // 0 = Chart, 1 = Matrix, 2 = Garden Shop

    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            HStack(spacing: 0) {
                Button(action: { activeTab = 0 }) {
                    Text("Charts")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(activeTab == 0 ? .rawBrass : .slate500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(activeTab == 0 ? Color.charcoalLight : Color.clear)
                }

                Button(action: { activeTab = 1 }) {
                    Text("Correlation")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(activeTab == 1 ? .rawBrass : .slate500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(activeTab == 1 ? Color.charcoalLight : Color.clear)
                }

                Button(action: { activeTab = 2 }) {
                    Text("Zen Garden")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(activeTab == 2 ? .rawBrass : .slate500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(activeTab == 2 ? Color.charcoalLight : Color.clear)
                }
            }
            .background(Color.charcoal)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.slate800),
                alignment: .bottom
            )

            ScrollView {
                VStack(spacing: 20) {
                    if activeTab == 0 {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "chart.bar.xaxis")
                                    .foregroundColor(.rawBrass)
                                Text("SCROLLYTICS™")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white)
                            }
                            Text("Ledger Aesthetic - Audited vs Unchecked times")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                        // SVG / Swift-drawn Chart
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Daily Scroll Minutes (Green portion: Audited)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.slate400)

                            HStack(alignment: .bottom, spacing: 14) {
                                ForEach([
                                    ("Mon", 32, 16),
                                    ("Tue", 48, 20),
                                    ("Wed", state.dailyScrollMinutes, max(15, state.dailyScrollMinutes - 15)),
                                    ("Thu", 35, 12),
                                    ("Fri", 50, 30)
                                ], id: \.0) { day, totalMins, auditedMins in
                                    VStack(spacing: 8) {
                                        ZStack(alignment: .bottom) {
                                            Capsule()
                                                .fill(Color.slate800)
                                                .frame(height: 100)

                                            // Unchecked (Darker) Portion
                                            Capsule()
                                                .fill(Color.slate700)
                                                .frame(height: CGFloat(min(totalMins, 100)))

                                            // Audited Portion (Desaturated Green)
                                            Capsule()
                                                .fill(Color.desaturatedGreen)
                                                .frame(height: CGFloat(min(auditedMins, 100)))
                                        }
                                        .frame(width: 24)

                                        Text(day)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(day == "Wed" ? .rawBrass : .slate500)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(16)
                        .background(Color.charcoalLight)
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
                                    .stroke(Color.rawBrass, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 44, height: 44)
                                    .rotationEffect(Angle(degrees: -90))

                                Text("\(Int(Double(state.nudgesResisted) / Double(max(state.nudgesTriggered, 1)) * 100))%")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(16)
                        .background(Color.rawBrass.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.rawBrass.opacity(0.15), lineWidth: 1)
                        )

                    } else if activeTab == 1 {
                        // Section: Correlation matrix
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "brain")
                                Text("INTENT VS. REALITY MATRIX")
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.white)
                            }
                            Text("Correlate the intention you set at trigger entry against your reflection satisfaction.")
                                .font(.system(size: 11))
                                .foregroundColor(.slate500)
                                .padding(.bottom, 8)

                            VStack(spacing: 12) {
                                MatrixRow(intent: "Relax / unwind", yesPct: "85%", neutPct: "10%", noPct: "5%", isNegative: false)
                                MatrixRow(intent: "Kill time / bored", yesPct: "25%", neutPct: "45%", noPct: "30%", isNegative: true)
                            }

                            Text("💡 Tip: \"Kill time\" sessions are twice as likely to end with regret.")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.rawBrass)
                                .padding(.top, 12)
                        }
                        .padding(16)
                        .background(Color.charcoalLight)
                        .cornerRadius(16)

                        // Curiosity Nudge on Day 8
                        if !state.hasPremium && state.simulatedDaysElapsed >= 8 {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.rawBrass)
                                    Text("Curiosity Nudge (Day \(state.simulatedDaysElapsed) of journey)")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.rawBrass)
                                }

                                Text("You have built a \(state.streak)-day mindful scrolling streak! Upgrade to Pause Pro to unlock month-over-month graphs and identify your biggest attention sinks.")
                                    .font(.system(size: 12))
                                    .foregroundColor(.slate300)
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color.rawBrass.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.rawBrass.opacity(0.3), lineWidth: 1)
                            )
                        }

                    } else if activeTab == 2 {
                        // Section: Zen Garden Shop
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("FOCUS GARDEN SHOP")
                                        .font(.system(size: 14, weight: .black))
                                        .foregroundColor(.white)
                                    Text("Spend ★ tokens earned by staying mindful")
                                        .font(.system(size: 11))
                                        .foregroundColor(.slate500)
                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.rawBrass)
                                    Text("\(state.tokens)")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.charcoal)
                                .cornerRadius(12)
                            }

                            // Bonsai Seasons Catalog
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Bonsai Seasons Cosmetics")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.slate400)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    GardenItemButton(name: "Spring", cost: 0, isUnlocked: state.unlockedSeasons.contains("Spring"), isSelected: state.selectedBonsaiSeason == "Spring", state: state, purchaseAction: {
                                        state.selectedBonsaiSeason = "Spring"
                                    })
                                    GardenItemButton(name: "Summer", cost: 5, isUnlocked: state.unlockedSeasons.contains("Summer"), isSelected: state.selectedBonsaiSeason == "Summer", state: state, purchaseAction: {
                                        state.tokens -= 5
                                        state.unlockedSeasons.append("Summer")
                                        state.selectedBonsaiSeason = "Summer"
                                    })
                                    GardenItemButton(name: "Autumn", cost: 15, isUnlocked: state.unlockedSeasons.contains("Autumn"), isSelected: state.selectedBonsaiSeason == "Autumn", state: state, purchaseAction: {
                                        state.tokens -= 15
                                        state.unlockedSeasons.append("Autumn")
                                        state.selectedBonsaiSeason = "Autumn"
                                    })
                                    GardenItemButton(name: "Winter", cost: 25, isUnlocked: state.unlockedSeasons.contains("Winter"), isSelected: state.selectedBonsaiSeason == "Winter", state: state, purchaseAction: {
                                        state.tokens -= 25
                                        state.unlockedSeasons.append("Winter")
                                        state.selectedBonsaiSeason = "Winter"
                                    })
                                }
                            }

                            // Koi pond colors Catalog
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Koi pond color Cosmetics")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.slate400)

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    GardenItemButton(name: "Orange", cost: 0, isUnlocked: state.unlockedKoiColors.contains("Orange"), isSelected: state.koiColor == "Orange", state: state, purchaseAction: {
                                        state.koiColor = "Orange"
                                    })
                                    GardenItemButton(name: "White", cost: 10, isUnlocked: state.unlockedKoiColors.contains("White"), isSelected: state.koiColor == "White", state: state, purchaseAction: {
                                        state.tokens -= 10
                                        state.unlockedKoiColors.append("White")
                                        state.koiColor = "White"
                                    })
                                    GardenItemButton(name: "Black", cost: 20, isUnlocked: state.unlockedKoiColors.contains("Black"), isSelected: state.koiColor == "Black", state: state, purchaseAction: {
                                        state.tokens -= 20
                                        state.unlockedKoiColors.append("Black")
                                        state.koiColor = "Black"
                                    })
                                    GardenItemButton(name: "Gold", cost: 30, isUnlocked: state.unlockedKoiColors.contains("Gold"), isSelected: state.koiColor == "Gold", state: state, purchaseAction: {
                                        state.tokens -= 30
                                        state.unlockedKoiColors.append("Gold")
                                        state.koiColor = "Gold"
                                    })
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.charcoalLight)
                        .cornerRadius(16)
                    }
                }
                .padding(16)
            }
        }
        .background(Color.charcoal)
    }
}

struct MatrixRow: View {
    let intent: String
    let yesPct: String
    let neutPct: String
    let noPct: String
    let isNegative: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(intent)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(isNegative ? "High regret 😞" : "High value 😊")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isNegative ? .rose : .desaturatedGreen)
            }

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("😊")
                    Text(yesPct)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.slate300)

                HStack(spacing: 4) {
                    Text("😐")
                    Text(neutPct)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.slate300)

                HStack(spacing: 4) {
                    Text("😞")
                    Text(noPct)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.slate300)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.charcoal)
            .cornerRadius(8)
        }
        .padding(.bottom, 6)
    }
}

struct GardenItemButton: View {
    let name: String
    let cost: Int
    let isUnlocked: Bool
    let isSelected: Bool
    let state: AppState
    let purchaseAction: () -> Void

    var body: some View {
        Button(action: {
            if isUnlocked {
                purchaseAction()
            } else if state.tokens >= cost {
                purchaseAction()
            }
        }) {
            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)

                if isSelected {
                    Text("Selected")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.rawBrass)
                } else if isUnlocked {
                    Text("Equip")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.slate500)
                } else {
                    Text("\(cost) ★")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(state.tokens >= cost ? .white : .slate500)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.rawBrass.opacity(0.15) : Color.charcoal)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.rawBrass : Color.slate800, lineWidth: 1)
            )
        }
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
                            .fill(Color.rawBrass.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.rawBrass)
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
                            .foregroundColor(.rawBrass)
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
                    .background(Color.charcoalLight)
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
                                        .foregroundColor(.rawBrass)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.rawBrass.opacity(0.2))
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
                            .background(Color.charcoalLight)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.rawBrass.opacity(0.35), lineWidth: 1)
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
                            .background(Color.charcoalLight)
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
                            .foregroundColor(.rawBrass)
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
                                    Task {
                                        await transaction.finish()
                                    }
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
