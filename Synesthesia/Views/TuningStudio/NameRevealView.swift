import SwiftUI

/// Cinematic reveal of the user's name transliterated into the generated language.
struct NameRevealView: View {
    let name: TransliteratedName
    @Binding var path: [ContentView.Screen]
    @EnvironmentObject var appState: AppState

    @State private var showName = false
    @State private var showPronunciation = false
    @State private var showDescription = false
    @State private var showButton = false

    var body: some View {
        ZStack {
            if let mood = appState.activeLanguage?.moodProfile {
                GradientBackground(mood: mood)
            } else {
                GradientBackground()
            }

            VStack(spacing: 32) {
                Spacer()

                if let lang = appState.activeLanguage {
                    Text("In \(lang.name), you are called")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .opacity(showName ? 1 : 0)
                }

                Text(name.transliterated)
                    .font(.system(size: 42, weight: .light, design: .serif))
                    .foregroundStyle(.white)
                    .opacity(showName ? 1 : 0)
                    .scaleEffect(showName ? 1 : 0.8)

                Text("/\(name.pronunciation)/")
                    .font(.system(size: 16, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
                    .opacity(showPronunciation ? 1 : 0)

                Button {
                    appState.audioService.speakIPA(name.pronunciation)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: appState.audioService.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                        Text("Listen")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                }
                .opacity(showPronunciation ? 1 : 0)

                Text("\"\(name.poeticDescription)\"")
                    .font(.subheadline.italic())
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(showDescription ? 1 : 0)

                Spacer()

                if let language = appState.activeLanguage {
                    Button {
                        path.append(.languageExplorer(language))
                    } label: {
                        Text("Explore Your Language")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .opacity(showButton ? 1 : 0)
                }
            }
            .padding()
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
        .onAppear { animateReveal() }
    }

    private func animateReveal() {
        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
            showName = true
        }
        withAnimation(.easeOut(duration: 0.8).delay(1.8)) {
            showPronunciation = true
        }
        withAnimation(.easeOut(duration: 0.8).delay(3.0)) {
            showDescription = true
        }
        withAnimation(.easeOut(duration: 0.6).delay(4.2)) {
            showButton = true
        }
    }
}
