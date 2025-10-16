import Foundation
import FirebaseFirestore

protocol FirestoreRepository {
    associatedtype Model: Codable
    
    var collectionName: String { get }
    
    func create(_ model: Model) async throws
    func get(id: String) async throws -> Model
    func update(_ model: Model) async throws
    func delete(id: String) async throws
    func getAll() async throws -> [Model]
}

extension FirestoreRepository {
    var db: Firestore {
        Firestore.firestore()
    }
    
    func decodeDocument(_ document: DocumentSnapshot) throws -> Model {
        guard document.exists, let data = document.data() else {
            throw RepositoryError.documentNotFound
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(Model.self, from: jsonData)
    }
    
    func encodeModel(_ model: Model) throws -> [String: Any] {
        let data = try JSONEncoder().encode(model)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RepositoryError.encodingError
        }
        return dictionary
    }
}
