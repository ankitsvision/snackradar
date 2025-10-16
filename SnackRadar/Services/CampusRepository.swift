import Foundation
import FirebaseFirestore
import Combine

protocol CampusRepositoryProtocol {
    func createCampus(_ campus: Campus) async throws
    func getCampus(id: String) async throws -> Campus
    func updateCampus(_ campus: Campus) async throws
    func deleteCampus(id: String) async throws
    func getAllCampuses() async throws -> [Campus]
    func getActiveCampuses() async throws -> [Campus]
    func listenToActiveCampuses(completion: @escaping (Result<[Campus], RepositoryError>) -> Void) -> ListenerRegistration
}

class CampusRepository: CampusRepositoryProtocol {
    static let shared = CampusRepository()
    private let db = Firestore.firestore()
    private let collectionName = "campuses"
    
    private init() {}
    
    func createCampus(_ campus: Campus) async throws {
        let docRef = db.collection(collectionName).document(campus.id)
        
        do {
            try docRef.setData(campus.asDictionary)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getCampus(id: String) async throws -> Campus {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists, let data = document.data() else {
                throw RepositoryError.documentNotFound
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let campus = try JSONDecoder().decode(Campus.self, from: jsonData)
            return campus
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateCampus(_ campus: Campus) async throws {
        let docRef = db.collection(collectionName).document(campus.id)
        
        do {
            try docRef.setData(campus.asDictionary, merge: true)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func deleteCampus(id: String) async throws {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            try await docRef.delete()
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getAllCampuses() async throws -> [Campus] {
        do {
            let query = db.collection(collectionName)
                .order(by: "name", descending: false)
            
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Campus.self, from: jsonData)
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getActiveCampuses() async throws -> [Campus] {
        do {
            let query = db.collection(collectionName)
                .whereField("isActive", isEqualTo: true)
                .order(by: "name", descending: false)
            
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Campus.self, from: jsonData)
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func listenToActiveCampuses(completion: @escaping (Result<[Campus], RepositoryError>) -> Void) -> ListenerRegistration {
        let query = db.collection(collectionName)
            .whereField("isActive", isEqualTo: true)
            .order(by: "name", descending: false)
        
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
                let campuses = try documents.compactMap { document -> Campus? in
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    return try JSONDecoder().decode(Campus.self, from: jsonData)
                }
                completion(.success(campuses))
            } catch {
                completion(.failure(.decodingError))
            }
        }
    }
}
