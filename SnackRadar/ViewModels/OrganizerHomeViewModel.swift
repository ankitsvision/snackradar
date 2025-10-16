import Foundation
import Combine

class OrganizerHomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showDeleteConfirmation: Bool = false
    @Published var eventToDelete: Event?
    
    private let eventRepository: EventRepositoryProtocol
    private let storageService: StorageService
    private let organizerId: String
    
    var liveEvents: [Event] {
        events.filter { $0.status == .live }
    }
    
    var upcomingEvents: [Event] {
        events.filter { $0.status == .upcoming }
    }
    
    var expiredEvents: [Event] {
        events.filter { $0.status == .expired }
    }
    
    init(
        organizerId: String,
        eventRepository: EventRepositoryProtocol = EventRepository.shared,
        storageService: StorageService = StorageService.shared
    ) {
        self.organizerId = organizerId
        self.eventRepository = eventRepository
        self.storageService = storageService
    }
    
    func loadEvents() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let fetchedEvents = try await eventRepository.getEventsByOrganizer(organizerId: organizerId)
            
            await MainActor.run {
                self.events = fetchedEvents
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func confirmDelete(_ event: Event) {
        eventToDelete = event
        showDeleteConfirmation = true
    }
    
    func deleteEvent() async {
        guard let event = eventToDelete else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            if event.imageUrl != nil {
                try? await storageService.deleteEventImage(eventId: event.id)
            }
            
            try await eventRepository.deleteEvent(id: event.id)
            
            await MainActor.run {
                events.removeAll { $0.id == event.id }
                eventToDelete = nil
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func cancelDelete() {
        eventToDelete = nil
        showDeleteConfirmation = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
