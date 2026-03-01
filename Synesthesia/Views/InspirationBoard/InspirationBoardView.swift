import SwiftUI
import PhotosUI

/// Canvas where users drop in visual inspiration (photos/images) to seed language generation.
struct InspirationBoardView: View {
    @EnvironmentObject var appState: AppState
    @Binding var path: [ContentView.Screen]

    @State private var sources: [InspirationSource] = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isAnalyzing = false
    @State private var blendedMood: MoodProfile?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            GradientBackground(colors: blendedMood.map { [
                Color(hex: moodToHex($0.warmth, $0.energy)),
                Color(hex: moodToHex($0.organic, $0.darkness)),
                Color(red: 0.05, green: 0.03, blue: 0.12)
            ] })

            ScrollView {
                VStack(spacing: 24) {
                    header
                    photoPicker
                    sourceGrid
                    if !sources.isEmpty { blendButton }
                    if let error = errorMessage { errorView(error) }
                }
                .padding()
            }
        }
        .navigationTitle("Inspiration Board")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Text("Drop in your inspiration")
                .font(.title2.weight(.light))
                .foregroundStyle(.white)
            Text("Photos, places, textures — anything that feels like your language")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var photoPicker: some View {
        PhotosPicker(
            selection: $selectedItems,
            maxSelectionCount: 10,
            matching: .images
        ) {
            Label("Add Images", systemImage: "photo.on.rectangle.angled")
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .onChange(of: selectedItems) { _, newItems in
            Task { await loadImages(from: newItems) }
        }
    }

    private var sourceGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
            ForEach(Array(sources.enumerated()), id: \.element.id) { index, source in
                SourceThumbnailView(
                    source: source,
                    onWeightChanged: { newWeight in
                        sources[index].weight = newWeight
                    },
                    onRemove: {
                        sources.remove(at: index)
                    }
                )
            }
        }
    }

    private var blendButton: some View {
        Button {
            Task { await blendMoods() }
        } label: {
            HStack {
                if isAnalyzing {
                    ProgressView()
                        .tint(.white)
                }
                Text(isAnalyzing ? "Analyzing..." : "Blend Moods")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                isAnalyzing ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.white.opacity(0.15)),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .disabled(isAnalyzing || sources.isEmpty)
    }

    private func errorView(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.red)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Logic

    private func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            let source = InspirationSource(imageData: data)
            await MainActor.run { sources.append(source) }
        }
    }

    private func blendMoods() async {
        isAnalyzing = true
        errorMessage = nil
        do {
            let mood = try await appState.imageAnalysis.analyzeAndBlend(sources: sources)
            blendedMood = mood
            // Update sources with extracted moods
            for i in sources.indices {
                if let data = sources[i].imageData {
                    sources[i].extractedMood = try? await appState.imageAnalysis.analyzeMood(imageData: data)
                }
            }
            path.append(.moodProfile(mood))
        } catch {
            errorMessage = error.localizedDescription
        }
        isAnalyzing = false
    }

    private func moodToHex(_ a: Double, _ b: Double) -> String {
        let r = Int(max(0, min(255, 128 + a * 80)))
        let g = Int(max(0, min(255, 80 + b * 40)))
        let blue = Int(max(0, min(255, 100 - b * 50)))
        return String(format: "#%02X%02X%02X", r, g, blue)
    }
}

/// Thumbnail for a single inspiration source with weight slider.
struct SourceThumbnailView: View {
    let source: InspirationSource
    let onWeightChanged: (Double) -> Void
    let onRemove: () -> Void

    @State private var weight: Double

    init(source: InspirationSource, onWeightChanged: @escaping (Double) -> Void, onRemove: @escaping () -> Void) {
        self.source = source
        self.onWeightChanged = onWeightChanged
        self.onRemove = onRemove
        self._weight = State(initialValue: source.weight)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let data = source.imageData {
                    #if canImport(UIKit)
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    #endif
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(height: 120)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.white.opacity(0.3))
                        }
                }

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(6)
                }
            }

            HStack {
                Text("\(Int(weight * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 32)
                Slider(value: $weight, in: 0...1)
                    .tint(.white.opacity(0.5))
                    .onChange(of: weight) { _, newValue in
                        onWeightChanged(newValue)
                    }
            }
        }
    }
}
