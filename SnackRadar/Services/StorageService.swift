import Foundation
import FirebaseStorage
import UIKit

enum StorageError: LocalizedError {
    case compressionFailed
    case uploadFailed(String)
    case invalidURL
    case deletionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        case .invalidURL:
            return "Invalid download URL"
        case .deletionFailed(let message):
            return "Deletion failed: \(message)"
        }
    }
}

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    
    private init() {}
    
    func uploadEventImage(_ image: UIImage, eventId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.compressionFailed
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("events/\(eventId)/image.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            throw StorageError.uploadFailed(error.localizedDescription)
        }
    }
    
    func deleteEventImage(eventId: String) async throws {
        let storageRef = storage.reference()
        let imageRef = storageRef.child("events/\(eventId)/image.jpg")
        
        do {
            try await imageRef.delete()
        } catch {
            throw StorageError.deletionFailed(error.localizedDescription)
        }
    }
    
    func uploadPromoImage(_ image: UIImage, promoId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.compressionFailed
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("promos/\(promoId)/image.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        do {
            _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            throw StorageError.uploadFailed(error.localizedDescription)
        }
    }
    
    func deletePromoImage(promoId: String) async throws {
        let storageRef = storage.reference()
        let imageRef = storageRef.child("promos/\(promoId)/image.jpg")
        
        do {
            try await imageRef.delete()
        } catch {
            throw StorageError.deletionFailed(error.localizedDescription)
        }
    }
}
