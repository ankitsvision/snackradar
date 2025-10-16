import Foundation
import Combine
import FirebaseAuth

class CampusSelectionManager: ObservableObject {
    static let shared = CampusSelectionManager()
    
    @Published private(set) var selectedCampusId: String?
    @Published private(set) var selectedCampus: Campus?
    
    private let userDefaults = UserDefaults.standard
    private let selectedCampusKey = "selectedCampusId"
    private let userRepository = UserRepository.shared
    private let campusRepository = CampusRepository.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadSelectedCampus()
    }
    
    private func loadSelectedCampus() {
        if let savedCampusId = userDefaults.string(forKey: selectedCampusKey) {
            selectedCampusId = savedCampusId
            Task {
                await fetchCampusDetails(campusId: savedCampusId)
            }
        }
    }
    
    func selectCampus(_ campusId: String) async throws {
        selectedCampusId = campusId
        userDefaults.set(campusId, forKey: selectedCampusKey)
        
        await fetchCampusDetails(campusId: campusId)
        
        if let userId = Auth.auth().currentUser?.uid {
            try await userRepository.updateCampusId(uid: userId, campusId: campusId)
        }
    }
    
    func selectCampus(_ campus: Campus) async throws {
        selectedCampusId = campus.id
        selectedCampus = campus
        userDefaults.set(campus.id, forKey: selectedCampusKey)
        
        if let userId = Auth.auth().currentUser?.uid {
            try await userRepository.updateCampusId(uid: userId, campusId: campus.id)
        }
    }
    
    func clearSelection() async throws {
        selectedCampusId = nil
        selectedCampus = nil
        userDefaults.removeObject(forKey: selectedCampusKey)
        
        if let userId = Auth.auth().currentUser?.uid {
            try await userRepository.updateCampusId(uid: userId, campusId: "")
        }
    }
    
    func syncWithUserProfile(_ profile: UserProfile) async {
        if let campusId = profile.campusId, campusId != selectedCampusId {
            selectedCampusId = campusId
            userDefaults.set(campusId, forKey: selectedCampusKey)
            await fetchCampusDetails(campusId: campusId)
        }
    }
    
    private func fetchCampusDetails(campusId: String) async {
        do {
            let campus = try await campusRepository.getCampus(id: campusId)
            await MainActor.run {
                selectedCampus = campus
            }
        } catch {
            print("Error fetching campus details: \(error.localizedDescription)")
        }
    }
    
    func hasCampusSelected() -> Bool {
        return selectedCampusId != nil
    }
}
