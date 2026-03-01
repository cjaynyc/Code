import SwiftUI

/// Root navigation view for the app.
struct ContentView: View {
    @EnvironmentObject var appState: AppState

    enum Screen {
        case home
        case inspirationBoard
        case moodProfile(MoodProfile)
        case tuningStudio
        case nameReveal(TransliteratedName)
        case languageExplorer(Language)
    }

    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .home:
                        HomeView(path: $path)
                    case .inspirationBoard:
                        InspirationBoardView(path: $path)
                    case .moodProfile(let mood):
                        MoodProfileView(moodProfile: mood, path: $path)
                    case .tuningStudio:
                        TuningStudioView(path: $path)
                    case .nameReveal(let name):
                        NameRevealView(name: name, path: $path)
                    case .languageExplorer(let language):
                        LanguageExplorerView(language: language)
                    }
                }
        }
    }
}

extension ContentView.Screen: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home): return true
        case (.inspirationBoard, .inspirationBoard): return true
        case (.moodProfile(let a), .moodProfile(let b)): return a == b
        case (.tuningStudio, .tuningStudio): return true
        case (.nameReveal(let a), .nameReveal(let b)):
            return a.transliterated == b.transliterated
        case (.languageExplorer(let a), .languageExplorer(let b)):
            return a.id == b.id
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .home: hasher.combine("home")
        case .inspirationBoard: hasher.combine("board")
        case .moodProfile(let m): hasher.combine("mood"); hasher.combine(m.warmth)
        case .tuningStudio: hasher.combine("tuning")
        case .nameReveal(let n): hasher.combine("name"); hasher.combine(n.transliterated)
        case .languageExplorer(let l): hasher.combine("explorer"); hasher.combine(l.id)
        }
    }
}

/// Home screen showing existing languages and a create button.
struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var path: [ContentView.Screen]

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 32) {
                Text("Synesthesia")
                    .font(.system(size: 36, weight: .thin, design: .serif))
                    .foregroundStyle(.white)

                Text("See language. Hear color.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))

                if appState.languages.isEmpty {
                    createButton
                } else {
                    languageList
                    createButton
                }
            }
            .padding()
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }

    private var createButton: some View {
        Button {
            path.append(.inspirationBoard)
        } label: {
            Label("Create a Language", systemImage: "plus.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private var languageList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(appState.languages) { language in
                    Button {
                        path.append(.languageExplorer(language))
                    } label: {
                        GlassmorphicCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(language.name)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    if let desc = language.languageDescription {
                                        Text(desc)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.6))
                                            .lineLimit(2)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                    }
                }
            }
        }
    }
}
