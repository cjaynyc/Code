import SwiftUI
import PhotosUI

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
