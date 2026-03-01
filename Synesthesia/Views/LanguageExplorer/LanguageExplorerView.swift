import SwiftUI

/// Browse and interact with a generated language across multiple tabs.
struct LanguageExplorerView: View {
    let language: Language
    @EnvironmentObject var appState: AppState

    @State private var selectedTab: ExplorerTab = .overview

    enum ExplorerTab: String, CaseIterable {
        case overview = "Overview"
        case sounds = "Sounds"
        case grammar = "Grammar"
        case dictionary = "Dictionary"
        case phrases = "Phrases"
        case translator = "Translator"
    }

    var body: some View {
        ZStack {
            if let hexColors = language.identity?.flag.colors {
                GradientBackground(hexColors: hexColors)
            } else {
                GradientBackground(mood: language.moodProfile)
            }

            VStack(spacing: 0) {
                tabBar
                tabContent
            }
        }
        .navigationTitle(language.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(ExplorerTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedTab = tab }
                    } label: {
                        Text(tab.rawValue)
                            .font(.caption.weight(selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == tab ? .white.opacity(0.15) : .clear,
                                in: Capsule()
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        ScrollView {
            switch selectedTab {
            case .overview: overviewTab
            case .sounds: soundsTab
            case .grammar: grammarTab
            case .dictionary: dictionaryTab
            case .phrases: phrasesTab
            case .translator: translatorTab
            }
        }
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        VStack(spacing: 16) {
            if let desc = language.languageDescription {
                GlassmorphicCard {
                    Text(desc)
                        .font(.body.italic())
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }

            if let identity = language.identity {
                VStack(spacing: 16) {
                    Text("Language Identity")
                        .font(.title3.weight(.light))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 24) {
                        VStack(spacing: 8) {
                            FlagView(flag: identity.flag, sigil: identity.sigil)
                                .aspectRatio(3 / 2, contentMode: .fit)
                                .frame(maxWidth: 240)
                            Text("Flag")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                            if let desc = identity.flag.description {
                                Text(desc)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.3))
                                    .multilineTextAlignment(.center)
                            }
                            if identity.flag.customImageData != nil {
                                Label("Custom", systemImage: "photo.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }

                        VStack(spacing: 8) {
                            SigilView(sigil: identity.sigil, animated: true)
                                .frame(width: 120, height: 120)
                            Text("Sigil")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                            if let desc = identity.sigil.description {
                                Text(desc)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.3))
                                    .multilineTextAlignment(.center)
                            }
                            if identity.sigil.customImageData != nil {
                                Label("Custom", systemImage: "photo.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                statCard("Words", value: "\(language.lexicon.count)")
                statCard("Consonants", value: "\(language.phonology.consonants.count)")
                statCard("Vowels", value: "\(language.phonology.vowels.count)")
                statCard("Word Order", value: language.grammar.wordOrder)
                statCard("Type", value: language.grammar.morphologicalType)
                statCard("Phrases", value: "\(language.samplePhrases.count)")
            }
        }
        .padding()
    }

    private func statCard(_ label: String, value: String) -> some View {
        GlassmorphicCard {
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Sounds Tab

    private var soundsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            phonemeSection("Consonants", phonemes: language.phonology.consonants)
            phonemeSection("Vowels", phonemes: language.phonology.vowels)

            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Syllable Patterns")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(language.phonology.phonotacticRules.joined(separator: ", "))
                        .font(.body.monospaced())
                        .foregroundStyle(.white)
                    Text("Stress: \(language.phonology.stressPattern)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding()
    }

    private func phonemeSection(_ title: String, phonemes: [Phoneme]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                ForEach(phonemes) { phoneme in
                    Button {
                        appState.audioService.speakPhoneme(phoneme)
                    } label: {
                        VStack(spacing: 2) {
                            Text(phoneme.symbol)
                                .font(.system(size: 18, design: .monospaced))
                                .foregroundStyle(.white)
                            Text(phoneme.romanization)
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .frame(width: 56, height: 56)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    // MARK: - Grammar Tab

    private var grammarTab: some View {
        VStack(spacing: 12) {
            ForEach(language.grammar.rules, id: \.self) { rule in
                GlassmorphicCard {
                    Text(rule)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }

            if let cases = language.grammar.nounCases, !cases.isEmpty {
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Noun Cases")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                        Text(cases.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
            }

            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tense System")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    Text(language.grammar.tenseSystem.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
    }

    // MARK: - Dictionary Tab

    @State private var searchText = ""

    private var dictionaryTab: some View {
        VStack(spacing: 12) {
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
                .foregroundStyle(.white)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

            LazyVStack(spacing: 8) {
                ForEach(filteredLexicon) { entry in
                    GlassmorphicCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.word)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text(entry.englishTranslation)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("/\(entry.pronunciation)/")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.4))
                                Text(entry.partOfSpeech)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }

    private var filteredLexicon: [LexiconEntry] {
        if searchText.isEmpty { return language.lexicon }
        let query = searchText.lowercased()
        return language.lexicon.filter {
            $0.word.lowercased().contains(query) ||
            $0.englishTranslation.lowercased().contains(query)
        }
    }

    // MARK: - Phrases Tab

    private var phrasesTab: some View {
        VStack(spacing: 12) {
            ForEach(language.samplePhrases) { phrase in
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(phrase.conlang)
                                .font(.headline)
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                appState.audioService.speakPhrase(phrase)
                            } label: {
                                Image(systemName: "speaker.wave.2")
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                        Text("/\(phrase.pronunciation)/")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                        Text(phrase.english)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(phrase.literalTranslation)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
        }
        .padding()
    }

    // MARK: - Translator Tab

    @State private var inputText = ""
    @State private var translatedPhrase: Phrase?
    @State private var isTranslating = false

    private var translatorTab: some View {
        VStack(spacing: 16) {
            GlassmorphicCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("English")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                    TextField("Type a phrase...", text: $inputText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .onSubmit { Task { await translate() } }
                }
            }

            Button {
                Task { await translate() }
            } label: {
                HStack {
                    if isTranslating { ProgressView().tint(.white) }
                    Text(isTranslating ? "Translating..." : "Translate")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
            }
            .disabled(inputText.isEmpty || isTranslating)

            if let phrase = translatedPhrase {
                GlassmorphicCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(language.name)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                        HStack {
                            Text(phrase.conlang)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                appState.audioService.speakPhrase(phrase)
                            } label: {
                                Image(systemName: "speaker.wave.2")
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                        Text("/\(phrase.pronunciation)/")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.4))
                        Text(phrase.literalTranslation)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
        }
        .padding()
    }

    private func translate() async {
        guard !inputText.isEmpty else { return }
        isTranslating = true
        do {
            translatedPhrase = try await appState.languageGeneration.translate(
                english: inputText, language: language
            )
        } catch {
            // Silently fail for now; error handling can be enhanced later
        }
        isTranslating = false
    }
}
