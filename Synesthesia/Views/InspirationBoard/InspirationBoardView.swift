import SwiftUI
import PhotosUI

/// Canvas where users drop in visual inspiration (photos/images) to seed language generation.
struct InspirationBoardView: View {
    @EnvironmentObject var appState: AppState
    @Binding var path: [ContentView.Screen]

    @State private var sources: [InspirationSource] = []
    @State private var thumbnails: [UUID: UIImage] = [:]
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
                    if !sources.isEmpty { actionButtons }
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
            matching: .images,
            photoLibrary: .shared()
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
                    thumbnail: thumbnails[source.id],
                    onWeightChanged: { newWeight in
                        sources[index].weight = newWeight
                    },
                    onRemove: {
                        thumbnails.removeValue(forKey: source.id)
                        sources.remove(at: index)
                    }
                )
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
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

            if !appState.apiService.configuration.isConfigured {
                Text("No API key — blend will use random mood")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        GlassmorphicCard {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
        }
    }

    // MARK: - Logic

    private func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            do {
                // Load as our PhotoImage transferable (handles HEIC, JPEG, PNG)
                if let photo = try await item.loadTransferable(type: PhotoImage.self) {
                    let source = InspirationSource(imageData: photo.data)
                    await MainActor.run {
                        thumbnails[source.id] = photo.uiImage
                        sources.append(source)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load image: \(error.localizedDescription)"
                }
            }
        }
        // Clear selection so the picker can be re-used
        await MainActor.run { selectedItems = [] }
    }

    private func blendMoods() async {
        isAnalyzing = true
        errorMessage = nil

        if appState.apiService.configuration.isConfigured {
            // Real API analysis
            do {
                let mood = try await appState.imageAnalysis.analyzeAndBlend(sources: sources)
                blendedMood = mood
                path.append(.moodProfile(mood))
            } catch {
                errorMessage = error.localizedDescription
            }
        } else {
            // No API key — generate a random mood so the user can still explore the UI
            let mood = MoodProfile.random()
            blendedMood = mood
            path.append(.moodProfile(mood))
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

// MARK: - Photo Transferable

/// Transferable wrapper that properly loads photos from PhotosPicker.
struct PhotoImage: Transferable {
    let data: Data
    let uiImage: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw PhotoImageError.invalidData
            }
            // Compress to JPEG for API transmission
            let jpegData = image.jpegData(compressionQuality: 0.8) ?? data
            return PhotoImage(data: jpegData, uiImage: image)
        }
    }

    enum PhotoImageError: Error, LocalizedError {
        case invalidData
        var errorDescription: String? { "Could not read image data" }
    }
}

/// Thumbnail for a single inspiration source with weight slider.
struct SourceThumbnailView: View {
    let source: InspirationSource
    let thumbnail: UIImage?
    let onWeightChanged: (Double) -> Void
    let onRemove: () -> Void

    @State private var weight: Double

    init(source: InspirationSource, thumbnail: UIImage?, onWeightChanged: @escaping (Double) -> Void, onRemove: @escaping () -> Void) {
        self.source = source
        self.thumbnail = thumbnail
        self.onWeightChanged = onWeightChanged
        self.onRemove = onRemove
        self._weight = State(initialValue: source.weight)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let uiImage = thumbnail {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(height: 120)
                        .overlay {
                            ProgressView()
                                .tint(.white)
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
