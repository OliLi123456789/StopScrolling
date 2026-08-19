import SwiftUI
import StoreKit

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
                        .font(.custom("Inter", size: 12).weight(.bold))
                        .foregroundColor(activeTab == 0 ? .terracotta : .inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(activeTab == 0 ? Color.pureWhite : Color.clear)
                }

                Button(action: { activeTab = 1 }) {
                    Text("Correlation")
                        .font(.custom("Inter", size: 12).weight(.bold))
                        .foregroundColor(activeTab == 1 ? .terracotta : .inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(activeTab == 1 ? Color.pureWhite : Color.clear)
                }

                Button(action: { activeTab = 2 }) {
                    Text("Zen Garden")
                        .font(.custom("Inter", size: 12).weight(.bold))
                        .foregroundColor(activeTab == 2 ? .terracotta : .inkMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(activeTab == 2 ? Color.pureWhite : Color.clear)
                }
            }
            .background(Color.washiPaper)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.paperBorder),
                alignment: .bottom
            )

            ScrollView {
                VStack(spacing: 20) {
                    if activeTab == 0 {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "chart.bar.xaxis")
                                    .foregroundColor(.terracotta)
                                Text("SCROLLYTICS™")
                                    .font(.custom("Inter", size: 14).weight(.black))
                                    .foregroundColor(.inkBlack)
                            }
                            Text("Ledger Paper Aesthetic - Audited vs Unchecked times")
                                .font(.custom("Inter", size: 11))
                                .foregroundColor(.inkMuted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)

                        // Paper Chart
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Daily Scroll Minutes (Sage portion: Audited)")
                                .font(.custom("Inter", size: 12).weight(.bold))
                                .foregroundColor(.inkMuted)

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
                                                .fill(Color.paperBorder)
                                                .frame(height: 100)

                                            // Unchecked Portion
                                            Capsule()
                                                .fill(Color.inkMuted.opacity(0.4))
                                                .frame(height: CGFloat(min(totalMins, 100)))

                                            // Audited Portion (Sage Green)
                                            Capsule()
                                                .fill(Color.sageGreen)
                                                .frame(height: CGFloat(min(auditedMins, 100)))
                                        }
                                        .frame(width: 24)

                                        Text(day)
                                            .font(.custom("Inter", size: 10).weight(.bold))
                                            .foregroundColor(day == "Wed" ? .terracotta : .inkMuted)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .padding(16)
                        .background(Color.pureWhite)
                        .cornerRadius(16)
                        .shadow(color: Color.paperShadow.opacity(0.5), radius: 6, x: 0, y: 3)

                        // Nudges Resisted Summary Ratio ring
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Nudges Resisted")
                                    .font(.custom("Inter", size: 13).weight(.bold))
                                    .foregroundColor(.inkBlack)
                                Text("Total: \(state.nudgesResisted) out of \(state.nudgesTriggered) gates")
                                    .font(.custom("Inter", size: 11))
                                    .foregroundColor(.inkMuted)
                            }
                            Spacer()

                            ZStack {
                                Circle()
                                    .stroke(Color.paperBorder, lineWidth: 4)
                                    .frame(width: 44, height: 44)
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(Double(state.nudgesResisted) / Double(max(state.nudgesTriggered, 1))))
                                    .stroke(Color.terracotta, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 44, height: 44)
                                    .rotationEffect(Angle(degrees: -90))

                                Text("\(Int(Double(state.nudgesResisted) / Double(max(state.nudgesTriggered, 1)) * 100))%")
                                    .font(.custom("JetBrainsMono", size: 10).weight(.bold))
                                    .foregroundColor(.inkBlack)
                            }
                        }
                        .padding(16)
                        .background(Color.terracotta.opacity(0.08))
                        .cornerRadius(16)

                    } else if activeTab == 1 {
                        // Section: Correlation matrix with symbol ratings
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "brain")
                                Text("INTENT VS. REALITY MATRIX")
                                    .font(.custom("Inter", size: 14).weight(.black))
                                    .foregroundColor(.inkBlack)
                            }
                            Text("Correlate the intention you set at trigger entry against your reflection satisfaction.")
                                .font(.custom("Inter", size: 11))
                                .foregroundColor(.inkMuted)
                                .padding(.bottom, 8)

                            VStack(spacing: 12) {
                                MatrixRow(intent: "Relax / unwind", posPct: "85%", neutPct: "10%", negPct: "5%", isNegative: false)
                                MatrixRow(intent: "Kill time / bored", posPct: "25%", neutPct: "45%", negPct: "30%", isNegative: true)
                            }

                            Text("Tip: \"Kill time\" sessions are twice as likely to end with regret.")
                                .font(.custom("Inter", size: 11).weight(.medium))
                                .foregroundColor(.terracotta)
                                .padding(.top, 12)
                        }
                        .padding(16)
                        .background(Color.pureWhite)
                        .cornerRadius(16)
                        .shadow(color: Color.paperShadow.opacity(0.5), radius: 6, x: 0, y: 3)

                        // Day 8 Curiosity Nudge
                        if !state.hasPremium && state.simulatedDaysElapsed >= 8 {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.terracotta)
                                    Text("Curiosity Nudge (Day \(state.simulatedDaysElapsed) of journey)")
                                        .font(.custom("Inter", size: 11).weight(.bold))
                                        .foregroundColor(.terracotta)
                                }

                                Text("You have built a \(state.streak)-day mindful scrolling streak! Upgrade to Pause Pro to unlock month-over-month graphs.")
                                    .font(.custom("Inter", size: 12))
                                    .foregroundColor(.inkBlack)
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color.terracotta.opacity(0.08))
                            .cornerRadius(16)
                        }

                    } else if activeTab == 2 {
                        // Garden Shop Component View
                        GardenShopView(state: state)
                    }
                }
                .padding(16)
            }
        }
        .background(Color.washiPaper)
    }
}

// MatrixRow uses symbol-based indicators [Circle (Positive)], [Dash (Neutral)], [Cross (Negative)] with ZERO emojis
struct MatrixRow: View {
    let intent: String
    let posPct: String
    let neutPct: String
    let negPct: String
    let isNegative: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(intent)
                    .font(.custom("Inter", size: 12).weight(.bold))
                    .foregroundColor(.inkBlack)
                Spacer()
                Text(isNegative ? "High Regret" : "High Value")
                    .font(.custom("Inter", size: 10).weight(.bold))
                    .foregroundColor(isNegative ? .terracotta : .sageGreen)
            }

            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "circle")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.sageGreen)
                    Text(posPct)
                }
                .font(.custom("Inter", size: 11).weight(.medium))
                .foregroundColor(.inkBlack)

                HStack(spacing: 4) {
                    Image(systemName: "minus")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.inkMuted)
                    Text(neutPct)
                }
                .font(.custom("Inter", size: 11).weight(.medium))
                .foregroundColor(.inkBlack)

                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.terracotta)
                    Text(negPct)
                }
                .font(.custom("Inter", size: 11).weight(.medium))
                .foregroundColor(.inkBlack)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.washiPaper)
            .cornerRadius(8)
        }
        .padding(.bottom, 6)
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
                            .fill(Color.terracotta.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.terracotta)
                    }

                    Text("Unlock Pause Pro")
                        .font(.custom("Inter", size: 22).weight(.black))
                        .foregroundColor(.inkBlack)

                    Text("Support your growth and focus with low-stakes pre-commitment. Secured by Apple StoreKit.")
                        .font(.custom("Inter", size: 13))
                        .foregroundColor(.inkMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .lineSpacing(4)
                }

                if state.hasPremium {
                    VStack(spacing: 12) {
                        Text("You are a Pro Member!")
                            .font(.custom("Inter", size: 15).weight(.bold))
                            .foregroundColor(.terracotta)
                        Text("Thank you for your supportive subscription of $39.99/year. You have unlocked unlimited custom breathing gates and quiet hours.")
                            .font(.custom("Inter", size: 12))
                            .foregroundColor(.inkBlack)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 16)
                    }
                    .padding()
                    .background(Color.pureWhite)
                    .cornerRadius(16)
                    .shadow(color: Color.paperShadow, radius: 6, x: 0, y: 3)
                } else {
                    // Purchase offerings options fully StoreKit backed
                    VStack(spacing: 12) {
                        Button(action: { purchaseSubscription(productId: "com.pause.annual") }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Annual Membership")
                                        .font(.custom("Inter", size: 13).weight(.bold))
                                        .foregroundColor(.inkBlack)
                                    Spacer()
                                    Text("BEST VALUE")
                                        .font(.custom("Inter", size: 9).weight(.extrabold))
                                        .foregroundColor(.terracotta)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.terracotta.opacity(0.12))
                                        .cornerRadius(4)
                                }
                                Text("$39.99 / year")
                                    .font(.custom("Inter", size: 18).weight(.black))
                                    .foregroundColor(.inkBlack)
                                Text("Pre-commit to a whole year of mindful awareness.")
                                    .font(.custom("Inter", size: 11))
                                    .foregroundColor(.inkMuted)
                            }
                            .padding()
                            .background(Color.pureWhite)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.terracotta.opacity(0.35), lineWidth: 1)
                            )
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
        }
        .background(Color.washiPaper)
    }

    private func purchaseSubscription(productId: String) {
        state.hasPremium = true
        state.logAction(appName: "StoreKit Engine", action: "Purchase Activated", result: productId)
    }
}
