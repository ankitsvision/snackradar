import SwiftUI
import Combine

enum BannerType {
    case info
    case success
    case warning
    case error
}

struct BannerData {
    let message: String
    let type: BannerType
}

class AppState: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var notificationToken: String?
    @Published var bannerData: BannerData?
    @Published var showBannerFlag: Bool = false
    
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
    
    func showBanner(message: String, type: BannerType) {
        DispatchQueue.main.async {
            self.bannerData = BannerData(message: message, type: type)
            self.showBannerFlag = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showBannerFlag = false
            }
        }
    }
}
