import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

enum SessionState {
    case signedOut
    case loading
    case studentHome
    case organizerHome
    case organizerPendingApproval
}

class SessionViewModel: ObservableObject {
    @Published var sessionState: SessionState = .loading
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private var userProfileListener: ListenerRegistration?
    
    private let authService = AuthService.shared
    private let userRepository = UserRepository.shared
    private let pushNotificationManager = PushNotificationManager.shared
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
        userProfileListener?.remove()
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                Task {
                    await self.loadOrCreateUserProfile(for: user)
                }
            } else {
                DispatchQueue.main.async {
                    self.userProfile = nil
                    self.sessionState = .signedOut
                }
            }
        }
    }
    
    private func loadOrCreateUserProfile(for user: FirebaseAuth.User) async {
        do {
            let profile = try await userRepository.getUserProfile(uid: user.uid)
            
            DispatchQueue.main.async {
                self.userProfile = profile
                self.updateSessionState(for: profile)
                self.setupUserProfileListener(uid: user.uid)
            }
            
            if profile.pushNotificationsEnabled {
                await refreshPushToken(for: user.uid)
            }
        } catch RepositoryError.documentNotFound {
            DispatchQueue.main.async {
                self.sessionState = .signedOut
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.sessionState = .signedOut
            }
        }
    }
    
    private func refreshPushToken(for userId: String) async {
        guard pushNotificationManager.permissionStatus == .authorized else { return }
        
        do {
            try await pushNotificationManager.updatePushToken(for: userId)
        } catch {
            print("Error refreshing push token: \(error.localizedDescription)")
        }
    }
    
    private func setupUserProfileListener(uid: String) {
        userProfileListener?.remove()
        
        userProfileListener = userRepository.listenToUserProfile(uid: uid) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                    self.updateSessionState(for: profile)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func updateSessionState(for profile: UserProfile) {
        switch profile.userRole {
        case .student:
            sessionState = .studentHome
        case .organizer:
            sessionState = profile.isApproved ? .organizerHome : .organizerPendingApproval
        }
    }
    
    func createUserProfile(uid: String, email: String, role: UserRole) async throws {
        let profile = UserProfile(uid: uid, email: email, userRole: role)
        try await userRepository.createUserProfile(profile)
    }
    
    func signOut() {
        Task {
            if let userId = userProfile?.uid {
                do {
                    try await pushNotificationManager.removePushToken(for: userId)
                } catch {
                    print("Error removing push token on logout: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async {
                do {
                    self.userProfileListener?.remove()
                    self.userProfile = nil
                    try self.authService.signOut()
                    self.sessionState = .signedOut
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updatePushNotifications(enabled: Bool) async throws {
        guard let userId = userProfile?.uid else {
            throw NSError(domain: "SessionViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        if enabled {
            let granted = await pushNotificationManager.requestPermission()
            
            if granted {
                try await pushNotificationManager.updatePushToken(for: userId)
                try await userRepository.updatePushNotificationsEnabled(uid: userId, enabled: true)
            } else {
                throw NSError(domain: "SessionViewModel", code: -2, userInfo: [NSLocalizedDescriptionKey: "Notification permission denied"])
            }
        } else {
            try await userRepository.removePushToken(uid: userId)
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
