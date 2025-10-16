import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var notificationToken: String?
    
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
    
    func setError(_ error: String?) {
        DispatchQueue.main.async {
            self.errorMessage = error
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
