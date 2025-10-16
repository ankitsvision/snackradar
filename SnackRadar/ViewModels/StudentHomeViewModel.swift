import Foundation
import FirebaseFirestore
import Combine

@MainActor
class StudentHomeViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCampusId: String?
    
    private let eventRepository: EventRepositoryProtocol
    private let campusSelectionManager = CampusSelectionManager.shared
    private var eventsListener: ListenerRegistration?
    private var cancellables = Set<AnyCancellable>()
    
    init(eventRepository: EventRepositoryProtocol = EventRepository.shared) {
        self.eventRepository = eventRepository
        setupCampusObserver()
    }
    
    deinit {
        eventsListener?.remove()
    }
    
    private func setupCampusObserver() {
        campusSelectionManager.$selectedCampusId
            .sink { [weak self] campusId in
                self?.selectedCampusId = campusId
                self?.startListeningToEvents()
            }
            .store(in: &cancellables)
    }
    
    func startListeningToEvents() {
        eventsListener?.remove()
        
        guard let campusId = selectedCampusId else {
            events = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        eventsListener = eventRepository.listenToEvents(campusId: campusId, status: nil) { [weak self] result in
            Task { @MainActor [weak self] in
                self?.isLoading = false
                switch result {
                case .success(let events):
                    self?.events = events.filter { $0.status != .expired }
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error listening to events: \(error)")
                }
            }
        }
    }
    
    func getRemainingTime(for event: Event) -> String {
        let now = Date()
        
        if event.status == .upcoming {
            let timeInterval = event.startTime.timeIntervalSince(now)
            return formatTimeInterval(timeInterval, prefix: "Starts in")
        } else if event.status == .live {
            let timeInterval = event.endTime.timeIntervalSince(now)
            return formatTimeInterval(timeInterval, prefix: "Ends in")
        } else {
            return "Ended"
        }
    }
    
    private func formatTimeInterval(_ interval: TimeInterval, prefix: String) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(prefix) \(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(prefix) \(minutes)m"
        } else {
            return "\(prefix) < 1m"
        }
    }
    
    func getStatusBadgeColor(for status: EventStatus) -> (background: String, text: String) {
        switch status {
        case .live:
            return ("#34C759", "#FFFFFF")
        case .upcoming:
            return ("#FF9500", "#FFFFFF")
        case .expired:
            return ("#8E8E93", "#FFFFFF")
        }
    }
    
    func refreshEvents() {
        startListeningToEvents()
    }
}
