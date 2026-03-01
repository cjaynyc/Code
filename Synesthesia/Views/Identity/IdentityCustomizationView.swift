import SwiftUI
import PhotosUI

/// View for customizing language identity with custom photos for flag and sigil.
struct IdentityCustomizationView: View {
    @Binding var identity: LanguageIdentity?
    @Environment(\.dismiss) private var dismiss
    
    @State private var flagPickerItem: PhotosPickerItem?
    @State private var sigilPickerItem: PhotosPickerItem?
    @State private var isLoadingFlag = false
    @State private var isLoadingSigil = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Customize Identity")
                        .font(.title2.weight(.light))
                        .foregroundStyle(.white)
                        .padding(.top)
                    
                    if let error = errorMessage {
                        errorView(error)
                    }
                    
                    // Flag Customization
                    VStack(spacing: 16) {
                        Text("Flag")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        if let identity = identity {
                            FlagView(flag: identity.flag, sigil: identity.sigil)
                                .aspectRatio(3 / 2, contentMode: .fit)
                                .frame(maxWidth: 300)
                        }
                        
                        HStack(spacing: 12) {
                            PhotosPicker(
                                selection: $flagPickerItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Label(
                                    identity?.flag.customImageData == nil ? "Add Custom Flag" : "Change Flag",
                                    systemImage: "photo"
                                )
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isLoadingFlag)
                            
                            if identity?.flag.customImageData != nil {
                                Button {
                                    identity?.flag.customImageData = nil
                                    errorMessage = nil
                                } label: {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .padding()
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        
                        if isLoadingFlag {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .padding()
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
                    
                    // Sigil Customization
                    VStack(spacing: 16) {
                        Text("Sigil")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        if let identity = identity {
                            SigilView(sigil: identity.sigil)
                                .frame(width: 150, height: 150)
                        }
                        
                        HStack(spacing: 12) {
                            PhotosPicker(
                                selection: $sigilPickerItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Label(
                                    identity?.sigil.customImageData == nil ? "Add Custom Sigil" : "Change Sigil",
                                    systemImage: "photo"
                                )
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isLoadingSigil)
                            
                            if identity?.sigil.customImageData != nil {
                                Button {
                                    identity?.sigil.customImageData = nil
                                    errorMessage = nil
                                } label: {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .padding()
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        
                        if isLoadingSigil {
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .padding()
                    .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Customize Identity")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onChange(of: flagPickerItem) { _, newItem in
            Task { await loadFlagImage(from: newItem) }
        }
        .onChange(of: sigilPickerItem) { _, newItem in
            Task { await loadSigilImage(from: newItem) }
        }
    }
    
    private func errorView(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    private func loadFlagImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoadingFlag = true
        errorMessage = nil
        
        do {
            if let photo = try await item.loadTransferable(type: PhotoImage.self) {
                await MainActor.run {
                    identity?.flag.customImageData = photo.data
                    flagPickerItem = nil
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load flag image: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoadingFlag = false
        }
    }
    
    private func loadSigilImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        isLoadingSigil = true
        errorMessage = nil
        
        do {
            if let photo = try await item.loadTransferable(type: PhotoImage.self) {
                await MainActor.run {
                    identity?.sigil.customImageData = photo.data
                    sigilPickerItem = nil
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load sigil image: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isLoadingSigil = false
        }
    }
}
