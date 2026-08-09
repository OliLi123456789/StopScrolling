import SwiftUI

// Custom Settings Dashboard View
struct SettingsView: View {
    @ObservedObject var state: AppState
    @Environment(\.presentationMode) var presentationMode

    let allAvailableApps = ["Instagram", "TikTok", "YouTube", "Snapchat", "Reddit", "Facebook"]

    var body: some View {
        ZColor.background
            .ignoresSafeArea()
            .overlay(
                ScrollView {
                    VStack(spacing: 24) {
                        // Section: Pause duration
                        VStack(alignment: .leading, spacing: 10) {
                            Text("PAUSE DURATION")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.slate500)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach([5, 10, 15, 30], id: \.self) { sec in
                                    Button(action: {
                                        state.pauseDuration = sec
                                    }) {
                                        Text("\(sec)s")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(state.pauseDuration == sec ? .rawBrass : .slate300)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(state.pauseDuration == sec ? Color.rawBrass.opacity(0.15) : Color.charcoalLight)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(state.pauseDuration == sec ? Color.rawBrass : Color.slate800, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }

                        // Section: Intention toggle
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(isOn: $state.enableIntentionPrompt) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Intention Prompt")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Ask \"What are you here for?\" first")
                                        .font(.system(size: 11))
                                        .foregroundColor(.slate400)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(onColor: .rawBrass))
                        }
                        .padding()
                        .background(Color.charcoalLight)
                        .cornerRadius(12)

                        // Section: Edit Apps
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EDIT MANAGED APPS")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.slate500)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(allAvailableApps, id: \.self) { app in
                                    let contains = state.managedApps.contains(app)
                                    Button(action: {
                                        if contains {
                                            state.managedApps.removeAll { $0 == app }
                                        } else {
                                            state.managedApps.append(app)
                                        }
                                    }) {
                                        Text(app)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(contains ? .white : .slate500)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(contains ? Color.rawBrass.opacity(0.1) : Color.charcoalLight)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(contains ? Color.rawBrass.opacity(0.4) : Color.slate800, lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }

                        // Section: Quiet Hours
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(isOn: $state.enableQuietHours) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Quiet Hours")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Suppress overlays during custom times")
                                        .font(.system(size: 11))
                                        .foregroundColor(.slate400)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(onColor: .rawBrass))
                            .disabled(!state.hasPremium)

                            if !state.hasPremium {
                                Text("🔒 Premium Feature (Requires Pause+)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.rawBrass)
                            }
                        }
                        .padding()
                        .background(Color.charcoalLight)
                        .cornerRadius(12)

                        // Mandatory Data Deletion action
                        Button(action: {
                            state.resetState()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash")
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
                                    .stroke(Color.rose.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.top, 12)

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save & Return")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.slate900)
                                .cornerRadius(12)
                        }
                    }
                    .padding(24)
                }
            )
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// Custom binding helper for toggles
extension Toggle {
    func toggleStyle(onColor: Color) -> some View {
        self.modifier(ToggleColorModifier(onColor: onColor))
    }
}

struct ToggleColorModifier: ViewModifier {
    let onColor: Color
    func body(content: Content) -> some View {
        content // fallback
    }
}
