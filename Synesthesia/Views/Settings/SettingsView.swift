import SwiftUI

/// Settings screen for API key entry and app preferences.
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey: String = ""
    @State private var showKey = false
    @State private var saved = false

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView {
                VStack(spacing: 24) {
                    apiKeySection
                    connectionStatus
                    preferencesSection
                    aboutSection
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            apiKey = appState.settings.apiKey
        }
    }

    // MARK: - API Key

    private var apiKeySection: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Anthropic API Key", systemImage: "key.fill")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Required to generate languages. Get yours at console.anthropic.com")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))

                HStack {
                    Group {
                        if showKey {
                            TextField("sk-ant-...", text: $apiKey)
                        } else {
                            SecureField("sk-ant-...", text: $apiKey)
                        }
                    }
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))

                    Button {
                        showKey.toggle()
                    } label: {
                        Image(systemName: showKey ? "eye.slash" : "eye")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                Button {
                    appState.updateAPIKey(apiKey)
                    saved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
                } label: {
                    HStack {
                        Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        Text(saved ? "Saved" : "Save Key")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        saved ? AnyShapeStyle(Color.green.opacity(0.3)) : AnyShapeStyle(.white.opacity(0.15)),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                }
            }
        }
    }

    private var connectionStatus: some View {
        GlassmorphicCard {
            HStack(spacing: 12) {
                Circle()
                    .fill(appState.apiService.configuration.isConfigured ? .green : .red)
                    .frame(width: 10, height: 10)

                Text(appState.apiService.configuration.isConfigured
                    ? "API Connected"
                    : "No API Key")
                    .font(.subheadline)
                    .foregroundStyle(.white)

                Spacer()

                Text(appState.settings.preferredModel)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 16) {
                Label("Preferences", systemImage: "gearshape")
                    .font(.headline)
                    .foregroundStyle(.white)

                Toggle(isOn: $appState.settings.autoSaveEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto-Save")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text("Automatically save languages after changes")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .tint(.white.opacity(0.5))
                .onChange(of: appState.settings.autoSaveEnabled) { _, _ in
                    appState.saveSettings()
                }

                Toggle(isOn: $appState.settings.hapticFeedbackEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptic Feedback")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Text("Vibrate on key interactions")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .tint(.white.opacity(0.5))
                .onChange(of: appState.settings.hapticFeedbackEnabled) { _, _ in
                    appState.saveSettings()
                }
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        GlassmorphicCard {
            VStack(spacing: 8) {
                Text("Synesthesia")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("See language. Hear color.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                Text("v1.0")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
