import Foundation
import FirebaseFirestore

class MockEventRepository: EventRepositoryProtocol {
    var mockEvents: [Event] = []
    var shouldThrowError = false
    
    init() {
        mockEvents = MockDataProviders.sampleEvents
    }
    
    func createEvent(_ event: Event) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        mockEvents.append(event)
    }
    
    func getEvent(id: String) async throws -> Event {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        guard let event = mockEvents.first(where: { $0.id == id }) else {
            throw RepositoryError.documentNotFound
        }
        return event
    }
    
    func updateEvent(_ event: Event) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        if let index = mockEvents.firstIndex(where: { $0.id == event.id }) {
            mockEvents[index] = event
        }
    }
    
    func deleteEvent(id: String) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        mockEvents.removeAll(where: { $0.id == id })
    }
    
    func getEventsByCampus(campusId: String, status: EventStatus?) async throws -> [Event] {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        var filtered = mockEvents.filter { $0.campusId == campusId && $0.isApproved }
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        return filtered
    }
    
    func getEventsByOrganizer(organizerId: String) async throws -> [Event] {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        return mockEvents.filter { $0.organizerId == organizerId }
    }
    
    func listenToEvents(campusId: String?, status: EventStatus?, completion: @escaping (Result<[Event], RepositoryError>) -> Void) -> ListenerRegistration {
        var filtered = mockEvents
        if let campusId = campusId {
            filtered = filtered.filter { $0.campusId == campusId && $0.isApproved }
        }
        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }
        completion(.success(filtered))
        return MockListenerRegistration()
    }
    
    func approveEvent(id: String) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        if let index = mockEvents.firstIndex(where: { $0.id == id }) {
            mockEvents[index].isApproved = true
        }
    }
}

class MockCampusRepository: CampusRepositoryProtocol {
    var mockCampuses: [Campus] = []
    var shouldThrowError = false
    
    init() {
        mockCampuses = MockDataProviders.sampleCampuses
    }
    
    func createCampus(_ campus: Campus) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        mockCampuses.append(campus)
    }
    
    func getCampus(id: String) async throws -> Campus {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        guard let campus = mockCampuses.first(where: { $0.id == id }) else {
            throw RepositoryError.documentNotFound
        }
        return campus
    }
    
    func updateCampus(_ campus: Campus) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        if let index = mockCampuses.firstIndex(where: { $0.id == campus.id }) {
            mockCampuses[index] = campus
        }
    }
    
    func deleteCampus(id: String) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        mockCampuses.removeAll(where: { $0.id == id })
    }
    
    func getAllCampuses() async throws -> [Campus] {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        return mockCampuses
    }
    
    func getActiveCampuses() async throws -> [Campus] {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        return mockCampuses.filter { $0.isActive }
    }
    
    func listenToActiveCampuses(completion: @escaping (Result<[Campus], RepositoryError>) -> Void) -> ListenerRegistration {
        let activeCampuses = mockCampuses.filter { $0.isActive }
        completion(.success(activeCampuses))
        return MockListenerRegistration()
    }
}

class MockPromoRepository: PromoRepositoryProtocol {
    var mockPromos: [PromoPost] = []
    var shouldThrowError = false
    
    init() {
        mockPromos = MockDataProviders.samplePromos
    }
    
    func createPromo(_ promo: PromoPost) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        mockPromos.append(promo)
    }
    
    func getPromo(id: String) async throws -> PromoPost {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        guard let promo = mockPromos.first(where: { $0.id == id }) else {
            throw RepositoryError.documentNotFound
        }
        return promo
    }
    
    func updatePromo(_ promo: PromoPost) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        if let index = mockPromos.firstIndex(where: { $0.id == promo.id }) {
            mockPromos[index] = promo
        }
    }
    
    func deletePromo(id: String) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        mockPromos.removeAll(where: { $0.id == id })
    }
    
    func getPromosByCampus(campusId: String) async throws -> [PromoPost] {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        return mockPromos.filter { $0.campusId == campusId && $0.isApproved }
    }
    
    func getPromosByOrganizer(organizerId: String) async throws -> [PromoPost] {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        return mockPromos.filter { $0.organizerId == organizerId }
    }
    
    func listenToPromos(campusId: String, completion: @escaping (Result<[PromoPost], RepositoryError>) -> Void) -> ListenerRegistration {
        let filtered = mockPromos.filter { $0.campusId == campusId && $0.isApproved }
        completion(.success(filtered))
        return MockListenerRegistration()
    }
    
    func approvePromo(id: String) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        if let index = mockPromos.firstIndex(where: { $0.id == id }) {
            mockPromos[index].isApproved = true
        }
    }
    
    func pinPromo(id: String, isPinned: Bool) async throws {
        if shouldThrowError {
            throw RepositoryError.firestoreError("Mock error")
        }
        if let index = mockPromos.firstIndex(where: { $0.id == id }) {
            mockPromos[index].isPinned = isPinned
        }
    }
}

class MockListenerRegistration: ListenerRegistration {
    func remove() {}
}

struct MockDataProviders {
    static var sampleCampuses: [Campus] {
        [
            Campus(
                id: "campus1",
                name: "Downtown Campus",
                address: "123 Main St",
                city: "San Francisco",
                state: "CA",
                zipCode: "94102",
                latitude: 37.7749,
                longitude: -122.4194,
                isActive: true
            ),
            Campus(
                id: "campus2",
                name: "North Campus",
                address: "456 Oak Ave",
                city: "San Francisco",
                state: "CA",
                zipCode: "94103",
                latitude: 37.7849,
                longitude: -122.4094,
                isActive: true
            ),
            Campus(
                id: "campus3",
                name: "East Campus",
                address: "789 Pine Rd",
                city: "Oakland",
                state: "CA",
                zipCode: "94601",
                isActive: false
            )
        ]
    }
    
    static var sampleEvents: [Event] {
        let now = Date()
        let oneHour: TimeInterval = 3600
        let oneDay: TimeInterval = 86400
        
        return [
            Event(
                id: "event1",
                title: "Pizza Party",
                description: "Free pizza for all students! Come join us for a fun afternoon.",
                campusId: "campus1",
                organizerId: "org1",
                organizerName: "Student Union",
                location: "Student Center, Room 101",
                foodType: .pizza,
                startTime: now.addingTimeInterval(oneDay),
                endTime: now.addingTimeInterval(oneDay + 2 * oneHour),
                imageUrl: nil,
                isApproved: true
            ),
            Event(
                id: "event2",
                title: "Taco Tuesday",
                description: "Enjoy free tacos and meet new friends!",
                campusId: "campus1",
                organizerId: "org2",
                organizerName: "Food Club",
                location: "Cafeteria",
                foodType: .dinner,
                startTime: now.addingTimeInterval(-oneHour),
                endTime: now.addingTimeInterval(oneHour),
                imageUrl: nil,
                isApproved: true
            ),
            Event(
                id: "event3",
                title: "Cookie Social",
                description: "Freshly baked cookies and socializing.",
                campusId: "campus2",
                organizerId: "org1",
                organizerName: "Student Union",
                location: "Library Plaza",
                foodType: .desserts,
                startTime: now.addingTimeInterval(-2 * oneDay),
                endTime: now.addingTimeInterval(-2 * oneDay + oneHour),
                imageUrl: nil,
                isApproved: true
            )
        ]
    }
    
    static var samplePromos: [PromoPost] {
        [
            PromoPost(
                id: "promo1",
                title: "20% Off Coffee",
                content: "Show your student ID and get 20% off all coffee drinks this week!",
                imageUrl: nil,
                campusId: "campus1",
                organizerId: "org1",
                organizerName: "Campus Cafe",
                isApproved: true,
                isPinned: true
            ),
            PromoPost(
                id: "promo2",
                title: "Free Smoothie Friday",
                content: "Every Friday, get a free smoothie with any meal purchase.",
                imageUrl: nil,
                campusId: "campus1",
                organizerId: "org2",
                organizerName: "Juice Bar",
                isApproved: true,
                isPinned: false
            ),
            PromoPost(
                id: "promo3",
                title: "Student Meal Deal",
                content: "Lunch combo for only $5 - burger, fries, and a drink!",
                imageUrl: nil,
                campusId: "campus2",
                organizerId: "org3",
                organizerName: "Food Court",
                isApproved: true,
                isPinned: false
            )
        ]
    }
    
    static func sampleEvent(status: EventStatus = .live) -> Event {
        let now = Date()
        let oneHour: TimeInterval = 3600
        let oneDay: TimeInterval = 86400
        
        let (startTime, endTime): (Date, Date) = {
            switch status {
            case .upcoming:
                return (now.addingTimeInterval(oneDay), now.addingTimeInterval(oneDay + 2 * oneHour))
            case .live:
                return (now.addingTimeInterval(-oneHour), now.addingTimeInterval(oneHour))
            case .expired:
                return (now.addingTimeInterval(-2 * oneDay), now.addingTimeInterval(-2 * oneDay + oneHour))
            }
        }()
        
        return Event(
            id: UUID().uuidString,
            title: "Sample Event",
            description: "This is a sample event for preview.",
            campusId: "campus1",
            organizerId: "org1",
            organizerName: "Sample Organizer",
            location: "Sample Location",
            foodType: .pizza,
            startTime: startTime,
            endTime: endTime,
            isApproved: true
        )
    }
    
    static var sampleCampus: Campus {
        Campus(
            id: "campus1",
            name: "Downtown Campus",
            address: "123 Main St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102",
            latitude: 37.7749,
            longitude: -122.4194
        )
    }
    
    static var samplePromo: PromoPost {
        PromoPost(
            id: "promo1",
            title: "Sample Promo",
            content: "This is a sample promotional post for preview.",
            campusId: "campus1",
            organizerId: "org1",
            organizerName: "Sample Organizer",
            isApproved: true
        )
    }
}
