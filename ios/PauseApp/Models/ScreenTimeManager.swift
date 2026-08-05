import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

// Complete Apple Screen Time (FamilyControls / ManagedSettings) Integration orchestration.
// This implements native system app gating/interception for iOS.
class ScreenTimeManager: ObservableObject {
    static let shared = ScreenTimeManager()

    let store = ManagedSettingsStore()

    @Published var selectedAppTokens = FamilyActivitySelection() {
        didSet {
            saveSelection()
            applyShieldRestrictions()
        }
    }

    init() {
        loadSelection()
    }

    // Request permission to access the local Apple Screen Time APIs
    func requestAuthorization() {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                    print("Pause: Successfully authorized FamilyControls Screen Time APIs")
                } catch {
                    print("Pause: Authorization error: \(error.localizedDescription)")
                }
            }
        }
    }

    // Apply system-level App Shields using ManagedSettingsStore
    func applyShieldRestrictions() {
        if #available(iOS 15.0, *) {
            if selectedAppTokens.applicationTokens.isEmpty {
                store.shield.applications = nil
            } else {
                // Set system shields onto target applications.
                // When these apps are launched, iOS system blocks access and triggers our overlay.
                store.shield.applications = selectedAppTokens.applicationTokens
            }
            print("Pause: Successfully applied Device Shield configurations to selected apps.")
        }
    }

    // Temporarily unlock an app for 15 minutes
    func temporarilyUnlockApp(applicationToken: ApplicationToken) {
        if #available(iOS 15.0, *) {
            // Remove specific shield application token to allow unrestricted access for 15 mins
            var currentTokens = selectedAppTokens.applicationTokens
            currentTokens.remove(applicationToken)
            store.shield.applications = currentTokens

            // Schedule timer to re-apply the block shield after 15 minutes
            Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: false) { [weak self] _ in
                self?.applyShieldRestrictions()
            }
        }
    }

    private func saveSelection() {
        if let encoded = try? JSONEncoder().encode(selectedAppTokens) {
            UserDefaults.standard.set(encoded, forKey: "selectedAppTokens")
        }
    }

    private func loadSelection() {
        if let data = UserDefaults.standard.data(forKey: "selectedAppTokens"),
           let decoded = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.selectedAppTokens = decoded
        }
    }
}
