import SwiftUI
import FirebaseCore

@main
struct SnackRadarApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var appSession = AppSession()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appSession)
        }
    }
}
