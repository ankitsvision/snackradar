import SwiftUI
import FirebaseCore

@main
struct SnackRadarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var sessionViewModel = SessionViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(sessionViewModel)
                .onReceive(NotificationCenter.default.publisher(for: .didReceiveEventNotification)) { notification in
                    handleEventNotification(notification)
                }
        }
        .onChange(of: scenePhase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            PushNotificationManager.shared.clearBadge()
            
            if let userId = sessionViewModel.userProfile?.uid,
               sessionViewModel.userProfile?.pushNotificationsEnabled == true {
                Task {
                    do {
                        try await PushNotificationManager.shared.updatePushToken(for: userId)
                    } catch {
                        print("Error refreshing token on app active: \(error.localizedDescription)")
                    }
                }
            }
        case .inactive:
            break
        case .background:
            break
        @unknown default:
            break
        }
    }
    
    private func handleEventNotification(_ notification: Notification) {
        guard let eventId = notification.userInfo?["eventId"] as? String else { return }
        
        let isForeground = notification.userInfo?["foreground"] as? Bool ?? false
        
        if isForeground {
            appState.showBanner(message: "New event available!", type: .info)
        }
        
        print("Received event notification for eventId: \(eventId)")
    }
}
