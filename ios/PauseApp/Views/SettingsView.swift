import SwiftUI

// Custom Settings Dashboard View with Washi Paper styling and zero emojis
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
                                .font(.custom("Inter", size: 11).weight(.bold))
                                .foregroundColor(.inkMuted)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach([5, 10, 15, 30], id: \.self) { sec in
                                    Button(action: {
                                        state.pauseDuration = sec
                                    }) {
                                        Text("\(sec)s")
                                            .font(.custom("Inter", size: 13).weight(.bold))
                                            .foregroundColor(state.pauseDuration == sec ? .terracotta : .inkBlack)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(state.pauseDuration == sec ? Color.terracotta.opacity(0.12) : Color.pureWhite)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(state.pauseDuration == sec ? Color.terracotta : Color.paperBorder, lineWidth: 1)
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
                                        .font(.custom("Inter", size: 14).weight(.bold))
                                        .foregroundColor(.inkBlack)
                                    Text("Ask \"What are you here for?\" first")
                                        .font(.custom("Inter", size: 11))
                                        .foregroundColor(.inkMuted)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(onColor: .terracotta))
                        }
                        .padding()
                        .background(Color.pureWhite)
                        .cornerRadius(12)

                        // Section: Edit Apps
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EDIT MANAGED APPS")
                                .font(.custom("Inter", size: 11).weight(.bold))
                                .foregroundColor(.inkMuted)

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
                                            .font(.custom("Inter", size: 12).weight(.semibold))
                                            .foregroundColor(contains ? .inkBlack : .inkMuted)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(contains ? Color.terracotta.opacity(0.12) : Color.pureWhite)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(contains ? Color.terracotta : Color.paperBorder, lineWidth: 1)
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
                                        .font(.custom("Inter", size: 14).weight(.bold))
                                        .foregroundColor(.inkBlack)
                                    Text("Suppress overlays during custom times")
                                        .font(.custom("Inter", size: 11))
                                        .foregroundColor(.inkMuted)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(onColor: .terracotta))
                            .disabled(!state.hasPremium)
                        }
                        .padding()
                        .background(Color.pureWhite)
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
                            .font(.custom("Inter", size: 13).weight(.bold))
                            .foregroundColor(.terracotta)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.terracotta.opacity(0.1))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.terracotta.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .padding(.top, 12)

                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save & Return")
                                .font(.custom("Inter", size: 13).weight(.bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.terracotta)
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
