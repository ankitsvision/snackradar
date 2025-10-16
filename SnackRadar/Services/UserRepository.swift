import Foundation
import FirebaseFirestore

enum RepositoryError: LocalizedError {
    case documentNotFound
    case encodingError
    case decodingError
    case firestoreError(String)
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "User profile not found."
        case .encodingError:
            return "Failed to encode user data."
        case .decodingError:
            return "Failed to decode user data."
        case .firestoreError(let message):
            return message
        }
    }
}

class UserRepository {
    static let shared = UserRepository()
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    private init() {}
    
    func createUserProfile(_ profile: UserProfile) async throws {
        let docRef = db.collection(usersCollection).document(profile.uid)
        
        do {
            try docRef.setData(profile.asDictionary)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getUserProfile(uid: String) async throws -> UserProfile {
        let docRef = db.collection(usersCollection).document(uid)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists, let data = document.data() else {
                throw RepositoryError.documentNotFound
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let profile = try JSONDecoder().decode(UserProfile.self, from: jsonData)
            return profile
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        let docRef = db.collection(usersCollection).document(profile.uid)
        
        do {
            try docRef.setData(profile.asDictionary, merge: true)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updatePushToken(uid: String, token: String) async throws {
        let docRef = db.collection(usersCollection).document(uid)
        
        do {
            try await docRef.updateData(["pushToken": token])
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateCampusId(uid: String, campusId: String) async throws {
        let docRef = db.collection(usersCollection).document(uid)
        
        do {
            try await docRef.updateData(["campusId": campusId])
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateNotificationPreference(uid: String, enabled: Bool) async throws {
        let docRef = db.collection(usersCollection).document(uid)
        
        do {
            try await docRef.updateData(["notificationsEnabled": enabled])
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func requestRoleUpgrade(uid: String) async throws {
        let docRef = db.collection(usersCollection).document(uid)
        
        do {
            try await docRef.updateData([
                "roleUpgradeRequested": true,
                "userRole": UserRole.organizer.rawValue,
                "isApproved": false
            ])
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateSocialLinks(uid: String, socialLinks: SocialLinks?) async throws {
        let docRef = db.collection(usersCollection).document(uid)
        
        do {
            if let socialLinks = socialLinks {
                let socialLinksData = try JSONEncoder().encode(socialLinks)
                let socialLinksDict = try JSONSerialization.jsonObject(with: socialLinksData) as? [String: Any]
                try await docRef.updateData(["socialLinks": socialLinksDict ?? [:]])
            } else {
                try await docRef.updateData(["socialLinks": [:]])
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func listenToUserProfile(uid: String, completion: @escaping (Result<UserProfile, RepositoryError>) -> Void) -> ListenerRegistration {
        let docRef = db.collection(usersCollection).document(uid)
        
        return docRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(.firestoreError(error.localizedDescription)))
                return
            }
            
            guard let document = snapshot, document.exists, let data = document.data() else {
                completion(.failure(.documentNotFound))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let profile = try JSONDecoder().decode(UserProfile.self, from: jsonData)
                completion(.success(profile))
            } catch {
                completion(.failure(.decodingError))
            }
        }
    }
}
