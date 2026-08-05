import SwiftUI

// Theme helper defines consistent color tokens as solid fallback code colors.
struct ZColor {
    static let background = Color.slate950
    static let slate400 = Color.slate400
    static let slate500 = Color.slate500
    static let slate600 = Color.slate600
    static let slate800 = Color.slate800
    static let slate900 = Color.slate900
    static let slate950 = Color.slate950
}

// SwiftUI Color extension mapping hex-like fallback definitions.
extension Color {
    static let slate400 = Color(red: 148/255, green: 163/255, blue: 184/255)
    static let slate500 = Color(red: 100/255, green: 116/255, blue: 139/255)
    static let slate600 = Color(red: 71/255, green: 85/255, blue: 105/255)
    static let slate800 = Color(red: 30/255, green: 41/255, blue: 59/255)
    static let slate900 = Color(red: 15/255, green: 23/255, blue: 42/255)
    static let slate950 = Color(red: 2/255, green: 6/255, blue: 23/255)
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
    static let rose = Color(red: 244/255, green: 63/255, blue: 94/255)
    static let amber = Color(red: 245/255, green: 158/255, blue: 11/255)

    static var background: Color {
        return Color.slate950
    }
}

// Global App entrance orchestration and Tab-driven view containers.
@main
struct PauseApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(state: state)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @ObservedObject var state: AppState
    @State private var selectedTab = 0
    @State private var activeOverlayApp: String? = nil
    @State private var currentIntention: String? = nil
    @State private var showingIntentionPrompt = false

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
                            MainView(state: state, activeOverlayApp: $activeOverlayApp, currentTab: $selectedTab)
                                .tabItem {
                                    Label("Home", systemImage: "house")
                                }
                                .tag(0)

                            ScrollyticsView(state: state)
                                .tabItem {
                                    Label("Scrollytics", systemImage: "chart.bar.xaxis")
                                }
                                .tag(1)

                            PausePlusView(state: state)
                                .tabItem {
                                    Label("Pause+", systemImage: "crown")
                                }
                                .tag(2)
                        }
                        .accentColor(.indigo)
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
