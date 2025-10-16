import Foundation
import FirebaseFirestore
import Combine

protocol EventRepositoryProtocol {
    func createEvent(_ event: Event) async throws
    func getEvent(id: String) async throws -> Event
    func updateEvent(_ event: Event) async throws
    func deleteEvent(id: String) async throws
    func getEventsByCampus(campusId: String, status: EventStatus?) async throws -> [Event]
    func getEventsByOrganizer(organizerId: String) async throws -> [Event]
    func listenToEvents(campusId: String?, status: EventStatus?, completion: @escaping (Result<[Event], RepositoryError>) -> Void) -> ListenerRegistration
    func approveEvent(id: String) async throws
}

class EventRepository: EventRepositoryProtocol {
    static let shared = EventRepository()
    private let db = Firestore.firestore()
    private let collectionName = "events"
    
    private init() {}
    
    func createEvent(_ event: Event) async throws {
        let docRef = db.collection(collectionName).document(event.id)
        
        do {
            try docRef.setData(event.asDictionary)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getEvent(id: String) async throws -> Event {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists, let data = document.data() else {
                throw RepositoryError.documentNotFound
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let event = try JSONDecoder().decode(Event.self, from: jsonData)
            return event
        } catch let error as RepositoryError {
            throw error
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func updateEvent(_ event: Event) async throws {
        var updatedEvent = event
        updatedEvent.updatedAt = Date()
        
        let docRef = db.collection(collectionName).document(event.id)
        
        do {
            try docRef.setData(updatedEvent.asDictionary, merge: true)
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func deleteEvent(id: String) async throws {
        let docRef = db.collection(collectionName).document(id)
        
        do {
            try await docRef.delete()
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getEventsByCampus(campusId: String, status: EventStatus? = nil) async throws -> [Event] {
        do {
            var query: Query = db.collection(collectionName)
                .whereField("campusId", isEqualTo: campusId)
                .whereField("isApproved", isEqualTo: true)
            
            if let status = status {
                let now = Timestamp(date: Date())
                
                switch status {
                case .upcoming:
                    query = query.whereField("startTime", isGreaterThan: now)
                case .live:
                    query = query
                        .whereField("startTime", isLessThanOrEqualTo: now)
                        .whereField("endTime", isGreaterThanOrEqualTo: now)
                case .expired:
                    query = query.whereField("endTime", isLessThan: now)
                }
            }
            
            query = query.order(by: "startTime", descending: false)
            
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Event.self, from: jsonData)
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func getEventsByOrganizer(organizerId: String) async throws -> [Event] {
        do {
            let query = db.collection(collectionName)
                .whereField("organizerId", isEqualTo: organizerId)
                .order(by: "createdAt", descending: true)
            
            let snapshot = try await query.getDocuments()
            
            return try snapshot.documents.compactMap { document in
                let data = document.data()
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                return try JSONDecoder().decode(Event.self, from: jsonData)
            }
        } catch {
            throw RepositoryError.firestoreError(error.localizedDescription)
        }
    }
    
    func listenToEvents(
        campusId: String? = nil,
        status: EventStatus? = nil,
        completion: @escaping (Result<[Event], RepositoryError>) -> Void
    ) -> ListenerRegistration {
        var query: Query = db.collection(collectionName)
        
        if let campusId = campusId {
            query = query.whereField("campusId", isEqualTo: campusId)
        }
        
        query = query.whereField("isApproved", isEqualTo: true)
        
        if let status = status {
            let now = Timestamp(date: Date())
            
            switch status {
            case .upcoming:
                query = query.whereField("startTime", isGreaterThan: now)
            case .live:
                query = query
                    .whereField("startTime", isLessThanOrEqualTo: now)
                    .whereField("endTime", isGreaterThanOrEqualTo: now)
            case .expired:
                query = query.whereField("endTime", isLessThan: now)
            }
        }
        
        query = query.order(by: "startTime", descending: false)
        
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
                let events = try documents.compactMap { document -> Event? in
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    return try JSONDecoder().decode(Event.self, from: jsonData)
                }
                completion(.success(events))
            } catch {
                completion(.failure(.decodingError))
            }
        }
    }
    
    func approveEvent(id: String) async throws {
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
}
