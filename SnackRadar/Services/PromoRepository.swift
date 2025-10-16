import Foundation
import FirebaseFirestore
import Combine

protocol PromoRepositoryProtocol {
    func createPromo(_ promo: PromoPost) async throws
    func getPromo(id: String) async throws -> PromoPost
    func updatePromo(_ promo: PromoPost) async throws
    func deletePromo(id: String) async throws
    func getPromosByCampus(campusId: String) async throws -> [PromoPost]
    func getPromosByOrganizer(organizerId: String) async throws -> [PromoPost]
    func listenToPromos(campusId: String, completion: @escaping (Result<[PromoPost], RepositoryError>) -> Void) -> ListenerRegistration
    func approvePromo(id: String) async throws
    func pinPromo(id: String, isPinned: Bool) async throws
}

class PromoRepository: PromoRepositoryProtocol {
    static let shared = PromoRepository()
    private let db = Firestore.firestore()
    private let collectionName = "promos"
    
    private init() {}
    
    func createPromo(_ promo: PromoPost) async throws {
        let docRef = db.collection(collectionName).document(promo.id)
        
        do {
            try docRef.setData(promo.asDictionary)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getPromo(id: String) async throws -> PromoPost {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists, let data = document.data() else {
                throw RepositoryError.documentNotFound
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let promo = try JSONDecoder().decode(PromoPost.self, from: jsonData)
            return promo
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updatePromo(_ promo: PromoPost) async throws {
        var updatedPromo = promo
        updatedPromo.updatedAt = Date()
        
        let docRef = db.collection(collectionName).document(promo.id)
        
        do {
            try docRef.setData(updatedPromo.asDictionary, merge: true)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func deletePromo(id: String) async throws {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            try await docRef.delete()
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getPromosByCampus(campusId: String) async throws -> [PromoPost] {
        do {
            let query = db.collection(collectionName)
                .whereField("campusId", isEqualTo: campusId)
                .whereField("isApproved", isEqualTo: true)
                .order(by: "isPinned", descending: true)
                .order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(PromoPost.self, from: jsonData)
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getPromosByOrganizer(organizerId: String) async throws -> [PromoPost] {
        do {
            let query = db.collection(collectionName)
                .whereField("organizerId", isEqualTo: organizerId)
                .order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(PromoPost.self, from: jsonData)
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func listenToPromos(
        campusId: String,
        completion: @escaping (Result<[PromoPost], RepositoryError>) -> Void
    ) -> ListenerRegistration {
        let query = db.collection(collectionName)
            .whereField("campusId", isEqualTo: campusId)
            .whereField("isApproved", isEqualTo: true)
            .order(by: "isPinned", descending: true)
            .order(by: "createdAt", descending: true)
        
        return query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(.firestoreError(error.localizedDescription)))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            do {
                let promos = try documents.compactMap { document -> PromoPost? in
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    return try JSONDecoder().decode(PromoPost.self, from: jsonData)
                }
                completion(.success(promos))
            } catch {
                completion(.failure(.decodingError))
            }
        }
    }
    
    func approvePromo(id: String) async throws {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            try await docRef.updateData([
                "isApproved": true,
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func pinPromo(id: String, isPinned: Bool) async throws {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            try await docRef.updateData([
                "isPinned": isPinned,
                "updatedAt": Timestamp(date: Date())
            ])
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
}
