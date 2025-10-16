import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var availableCampuses: [Campus] = []
    @Published var selectedCampus: Campus?
    @Published var notificationsEnabled: Bool = false
    @Published var socialLinks: SocialLinks = SocialLinks()
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let userRepository = UserRepository.shared
    private let campusRepository = CampusRepository.shared
    private let campusSelectionManager = CampusSelectionManager.shared
    private let pushNotificationManager = PushNotificationManager.shared
    
    private var sessionViewModel: SessionViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init(sessionViewModel: SessionViewModel? = nil) {
        self.sessionViewModel = sessionViewModel
        setupObservers()
    }
    
    private func setupObservers() {
        pushNotificationManager.$isEnabled
            .sink { [weak self] isEnabled in
                self?.notificationsEnabled = isEnabled
            }
            .store(in: &cancellables)
    }
    
    func loadProfile(_ profile: UserProfile) {
        self.userProfile = profile
        self.notificationsEnabled = profile.notificationsEnabled
        self.socialLinks = profile.socialLinks ?? SocialLinks()
        
        Task {
            await loadCampuses()
            if let campusId = profile.campusId {
                await loadSelectedCampus(campusId: campusId)
            }
        }
    }
    
    private func loadCampuses() async {
        do {
            let campuses = try await campusRepository.getActiveCampuses()
            self.availableCampuses = campuses
        } catch {
            self.errorMessage = "Failed to load campuses: \(error.localizedDescription)"
        }
    }
    
    private func loadSelectedCampus(campusId: String) async {
        do {
            let campus = try await campusRepository.getCampus(id: campusId)
            self.selectedCampus = campus
        } catch {
            print("Failed to load campus: \(error.localizedDescription)")
        }
    }
    
    func updateCampus(_ campus: Campus) async {
        guard let uid = userProfile?.uid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await campusSelectionManager.selectCampus(campus)
            try await userRepository.updateCampusId(uid: uid, campusId: campus.id)
            
            self.selectedCampus = campus
            self.successMessage = "Campus updated successfully"
            
            await sessionViewModel?.refreshUserProfile()
            
            NotificationCenter.default.post(name: NSNotification.Name("RefreshEvents"), object: nil)
        } catch {
            self.errorMessage = "Failed to update campus: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func toggleNotifications() async {
        guard let uid = userProfile?.uid else { return }
        
        let currentStatus = pushNotificationManager.permissionStatus
        let targetValue = !notificationsEnabled
        
        switch currentStatus {
        case .notDetermined:
            if targetValue {
                pushNotificationManager.requestPermission { [weak self] granted in
                    Task { @MainActor [weak self] in
                        if granted {
                            await self?.updateNotificationPreference(uid: uid, enabled: true)
                        } else {
                            self?.notificationsEnabled = false
                        }
                    }
                }
            }
            
        case .denied:
            notificationsEnabled = false
            errorMessage = "Notifications are disabled. Please enable them in Settings."
            
        case .authorized, .provisional:
            await updateNotificationPreference(uid: uid, enabled: targetValue)
        }
    }
    
    private func updateNotificationPreference(uid: String, enabled: Bool) async {
        do {
            try await userRepository.updateNotificationPreference(uid: uid, enabled: enabled)
            
            if enabled {
                pushNotificationManager.isEnabled = true
            } else {
                pushNotificationManager.disableNotifications()
            }
            
            notificationsEnabled = enabled
            successMessage = enabled ? "Notifications enabled" : "Notifications disabled"
            
            await sessionViewModel?.refreshUserProfile()
        } catch {
            errorMessage = "Failed to update notification preference: \(error.localizedDescription)"
        }
    }
    
    func requestOrganizerRole() async {
        guard let uid = userProfile?.uid else { return }
        guard userProfile?.userRole == .student else {
            errorMessage = "You are already an organizer or have a pending request"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await userRepository.requestRoleUpgrade(uid: uid)
            successMessage = "Organizer role request submitted for admin approval"
            
            await sessionViewModel?.refreshUserProfile()
        } catch {
            errorMessage = "Failed to request organizer role: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func updateSocialLinks() async {
        guard let uid = userProfile?.uid else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let linksToSave = socialLinks.isEmpty ? nil : socialLinks
            try await userRepository.updateSocialLinks(uid: uid, socialLinks: linksToSave)
            successMessage = "Social links updated successfully"
            
            await sessionViewModel?.refreshUserProfile()
        } catch {
            errorMessage = "Failed to update social links: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func openNotificationSettings() {
        pushNotificationManager.openSystemSettings()
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
