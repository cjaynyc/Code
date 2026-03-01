import SwiftUI

/// The mixing board — hero screen where users tune linguistic parameters with sliders.
struct TuningStudioView: View {
    @EnvironmentObject var appState: AppState
    @Binding var path: [ContentView.Screen]

    @State private var tuning = TuningParameters.defaultValues
    @State private var showAdvanced = false
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var userName: String = ""
    @State private var showNameField = true

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView {
                VStack(spacing: 24) {
                    header

                    if showNameField {
                        nameInput
                    }

                    primarySliders
                    if showAdvanced { advancedSliders }
                    advancedToggle
                    generateButton

                    if let error = errorMessage { errorView(error) }
                }
                .padding()
            }
        }
        .navigationTitle("Tuning Studio")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Text("Shape Your Language")
                .font(.title2.weight(.light))
                .foregroundStyle(.white)
            Text("Drag the sliders to hear and feel the language change")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 20)
    }

    private var nameInput: some View {
        GlassmorphicCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Name")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.6))
                TextField("Enter your name", text: $userName)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var primarySliders: some View {
        VStack(spacing: 16) {
            LinguisticSlider(
                value: $tuning.harshToMelodic,
                leftLabel: "Harsh",
                rightLabel: "Melodic",
                description: "Consonant clusters vs flowing sounds"
            )
            LinguisticSlider(
                value: $tuning.ancientToModern,
                leftLabel: "Ancient",
                rightLabel: "Modern",
                description: "Complex morphology vs streamlined grammar"
            )
            LinguisticSlider(
                value: $tuning.sparseToOrnate,
                leftLabel: "Sparse",
                rightLabel: "Ornate",
                description: "Minimal words vs elaborate expressions"
            )
            LinguisticSlider(
                value: $tuning.aggressionLevel,
                leftLabel: "Gentle",
                rightLabel: "Aggressive",
                description: "Soft vowels vs guttural stops"
            )
        }
    }

    private var advancedSliders: some View {
        VStack(spacing: 16) {
            LinguisticSlider(
                value: $tuning.organicToMechanical,
                leftLabel: "Organic",
                rightLabel: "Mechanical",
                description: "Nature roots vs abstract roots"
            )
            LinguisticSlider(
                value: $tuning.intimateToFormal,
                leftLabel: "Intimate",
                rightLabel: "Formal",
                description: "Simple pronouns vs complex registers"
            )
            LinguisticSlider(
                value: $tuning.musicality,
                leftLabel: "Monotone",
                rightLabel: "Musical",
                description: "Flat rhythm vs tonal patterns"
            )
            LinguisticSlider(
                value: $tuning.alienFamiliar,
                leftLabel: "Alien",
                rightLabel: "Familiar",
                description: "Strange structures vs natural patterns"
            )
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var advancedToggle: some View {
        Button {
            withAnimation(.spring(response: 0.4)) {
                showAdvanced.toggle()
            }
        } label: {
            HStack {
                Text(showAdvanced ? "Hide Advanced" : "Show All Controls")
                    .font(.subheadline)
                Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
            }
            .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var generateButton: some View {
        Button {
            Task { await generate() }
        } label: {
            HStack {
                if isGenerating {
                    ProgressView().tint(.white)
                }
                Text(isGenerating ? "Generating..." : "Build My Language")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.white.opacity(isGenerating ? 0.05 : 0.15), in: RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isGenerating)
    }

    private func errorView(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Logic

    private func generate() async {
        isGenerating = true
        errorMessage = nil
        do {
            let sources = appState.activeLanguage?.inspirationSources ?? []
            let language = try await appState.createLanguage(
                from: sources,
                tuning: tuning,
                userName: userName.isEmpty ? nil : userName
            )
            path.append(.languageExplorer(language))
        } catch {
            errorMessage = error.localizedDescription
        }
        isGenerating = false
    }
}

/// Custom slider with descriptive labels at both ends.
struct LinguisticSlider: View {
    @Binding var value: Double
    let leftLabel: String
    let rightLabel: String
    let description: String

    var body: some View {
        GlassmorphicCard {
            VStack(spacing: 10) {
                HStack {
                    Text(leftLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(value < 0.4 ? 0.9 : 0.4))
                    Spacer()
                    Text(String(format: "%.0f%%", value * 100))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                    Text(rightLabel)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(value > 0.6 ? 0.9 : 0.4))
                }

                Slider(value: $value, in: 0...1)
                    .tint(.white.opacity(0.5))

                Text(description)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
}
