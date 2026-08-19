import SwiftUI

// Theme helper defines consistent color tokens for "Washi Paper" Minimalism
struct ZColor {
    static let background = Color.washiPaper
    static let pureWhite = Color.pureWhite
    static let paperShadow = Color.paperShadow
    static let terracotta = Color.terracotta
    static let sageGreen = Color.sageGreen
    static let dustyBlue = Color.dustyBlue
    static let inkBlack = Color.inkBlack
    static let inkMuted = Color.inkMuted
    static let paperBorder = Color.paperBorder
}

// SwiftUI Color extension mapping Washi Paper hex palette
extension Color {
    static let washiPaper = Color(red: 248/255, green: 246/255, blue: 240/255)
    static let pureWhite = Color.white
    static let paperShadow = Color(red: 229/255, green: 224/255, blue: 213/255)
    static let terracotta = Color(red: 224/255, green: 122/255, blue: 95/255)
    static let sageGreen = Color(red: 129/255, green: 178/255, blue: 154/255)
    static let dustyBlue = Color(red: 104/255, green: 162/255, blue: 185/255)
    static let inkBlack = Color(red: 43/255, green: 45/255, blue: 66/255)
    static let inkMuted = Color(red: 141/255, green: 143/255, blue: 154/255)
    static let paperBorder = Color(red: 232/255, green: 228/255, blue: 217/255)
    static let pazuOrange = Color(red: 217/255, green: 122/255, blue: 67/255)
    static let cream = Color(red: 253/255, green: 241/255, blue: 231/255)

    static var background: Color {
        return Color.washiPaper
    }
}

// Helper extension for Hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Global App entrance orchestration and Tab-driven view containers.
@main
struct PauseApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
                .preferredColorScheme(.light)
        }
    }
}

struct ContentView: View {
    @ObservedObject var state: AppState
    @State private var selectedTab = 0
    @State private var activeOverlayApp: String? = nil

    var body: some View {
        Group {
            if !state.isOnboarded {
                OnboardingView(state: state)
            } else {
                NavigationView {
                    ZStack {
                        ZColor.background
                            .ignoresSafeArea()

                        TabView(selection: $selectedTab) {
                            GardenView(state: state, activeOverlayApp: $activeOverlayApp)
                                .tabItem {
                                    Label("Home", systemImage: "house")
                                }
                                .tag(0)

                            ScrollyticsView(state: state)
                                .tabItem {
                                    Label("Scrollytics", systemImage: "chart.bar.xaxis")
                                }
                                .tag(1)

                            GardenShopView(state: state)
                                .tabItem {
                                    Label("Shop", systemImage: "bag")
                                }
                                .tag(2)

                            PausePlusView(state: state)
                                .tabItem {
                                    Label("Pause Pro", systemImage: "crown")
                                }
                                .tag(3)
                        }
                        .accentColor(.terracotta)
                    }
                    .navigationBarHidden(true)
                }
                .fullScreenCover(item: $activeOverlayApp) { app in
                    InterventionFlowView(appName: app, state: state, activeOverlayApp: $activeOverlayApp)
                }
            }
        }
    }
}

// Sub-struct helper allowing Binding fullScreenCover.
extension String: Identifiable {
    public var id: String { self }
}

// Orchestrates between the Intention Prompt (if enabled) and the Breathing Pause Gate.
struct InterventionFlowView: View {
    let appName: String
    @ObservedObject var state: AppState
    @Binding var activeOverlayApp: String?

    @State private var isPromptCompleted = false

    var body: some View {
        Group {
            if state.enableIntentionPrompt && !isPromptCompleted {
                IntentionPromptView(appName: appName) { choice in
                    state.logAction(appName: appName, action: "Intention Selected", result: choice)
                    withAnimation {
                        isPromptCompleted = true
                    }
                }
            } else {
                PauseGateView(appName: appName, state: state, activeOverlayApp: $activeOverlayApp)
            }
        }
    }
}
