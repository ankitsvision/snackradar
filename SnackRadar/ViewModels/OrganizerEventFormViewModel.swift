import Foundation
import SwiftUI
import Combine

enum FormMode {
    case create
    case edit(Event)
}

class OrganizerEventFormViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var location: String = ""
    @Published var foodType: FoodType = .other
    @Published var startDate: Date = Date().addingTimeInterval(3600)
    @Published var endDate: Date = Date().addingTimeInterval(7200)
    @Published var selectedImage: UIImage?
    @Published var existingImageUrl: String?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccess: Bool = false
    
    @Published var titleError: String?
    @Published var descriptionError: String?
    @Published var locationError: String?
    @Published var dateError: String?
    
    private let eventRepository: EventRepositoryProtocol
    private let storageService: StorageService
    private let notificationService: NotificationService
    private let mode: FormMode
    private let organizerId: String
    private let organizerName: String
    private let campusId: String
    
    var isEditMode: Bool {
        if case .edit = mode {
            return true
        }
        return false
    }
    
    var eventId: String? {
        if case .edit(let event) = mode {
            return event.id
        }
        return nil
    }
    
    init(
        mode: FormMode,
        organizerId: String,
        organizerName: String,
        campusId: String,
        eventRepository: EventRepositoryProtocol = EventRepository.shared,
        storageService: StorageService = StorageService.shared,
        notificationService: NotificationService = NotificationService.shared
    ) {
        self.mode = mode
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.campusId = campusId
        self.eventRepository = eventRepository
        self.storageService = storageService
        self.notificationService = notificationService
        
        if case .edit(let event) = mode {
            loadEventData(event)
        }
    }
    
    private func loadEventData(_ event: Event) {
        title = event.title
        description = event.description
        location = event.location
        foodType = event.foodType
        startDate = event.startTime
        endDate = event.endTime
        existingImageUrl = event.imageUrl
    }
    
    func validateForm() -> Bool {
        var isValid = true
        
        titleError = nil
        descriptionError = nil
        locationError = nil
        dateError = nil
        
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            titleError = "Title is required"
            isValid = false
        } else if title.count < 3 {
            titleError = "Title must be at least 3 characters"
            isValid = false
        } else if title.count > 100 {
            titleError = "Title must be less than 100 characters"
            isValid = false
        }
        
        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            descriptionError = "Description is required"
            isValid = false
        } else if description.count < 10 {
            descriptionError = "Description must be at least 10 characters"
            isValid = false
        } else if description.count > 500 {
            descriptionError = "Description must be less than 500 characters"
            isValid = false
        }
        
        if location.trimmingCharacters(in: .whitespaces).isEmpty {
            locationError = "Location is required"
            isValid = false
        } else if location.count < 3 {
            locationError = "Location must be at least 3 characters"
            isValid = false
        }
        
        if endDate <= startDate {
            dateError = "End time must be after start time"
            isValid = false
        }
        
        let now = Date()
        if startDate < now.addingTimeInterval(-300) {
            dateError = "Start time cannot be in the past"
            isValid = false
        }
        
        return isValid
    }
    
    func saveEvent() async {
        guard validateForm() else {
            return
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            var imageUrl = existingImageUrl
            
            if let image = selectedImage {
                let eventId = self.eventId ?? UUID().uuidString
                imageUrl = try await storageService.uploadEventImage(image, eventId: eventId)
            }
            
            switch mode {
            case .create:
                let event = Event(
                    title: title.trimmingCharacters(in: .whitespaces),
                    description: description.trimmingCharacters(in: .whitespaces),
                    campusId: campusId,
                    organizerId: organizerId,
                    organizerName: organizerName,
                    location: location.trimmingCharacters(in: .whitespaces),
                    foodType: foodType,
                    startTime: startDate,
                    endTime: endDate,
                    imageUrl: imageUrl,
                    isApproved: false
                )
                
                try await eventRepository.createEvent(event)
                
                await notificationService.scheduleEventNotification(for: event)
                
                await MainActor.run {
                    showSuccess = true
                }
                
            case .edit(let existingEvent):
                var updatedEvent = existingEvent
                updatedEvent.title = title.trimmingCharacters(in: .whitespaces)
                updatedEvent.description = description.trimmingCharacters(in: .whitespaces)
                updatedEvent.location = location.trimmingCharacters(in: .whitespaces)
                updatedEvent.foodType = foodType
                updatedEvent.startTime = startDate
                updatedEvent.endTime = endDate
                updatedEvent.imageUrl = imageUrl
                
                try await eventRepository.updateEvent(updatedEvent)
                
                await MainActor.run {
                    showSuccess = true
                }
            }
            
            await MainActor.run {
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
