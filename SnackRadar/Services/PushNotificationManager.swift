import Foundation
import UserNotifications
import UIKit

enum NotificationPermissionStatus {
    case notDetermined
    case denied
    case authorized
    case provisional
}

class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()
    
    @Published var permissionStatus: NotificationPermissionStatus = .notDetermined
    @Published var isEnabled: Bool = false
    
    private override init() {
        super.init()
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self?.permissionStatus = .notDetermined
                    self?.isEnabled = false
                case .denied:
                    self?.permissionStatus = .denied
                    self?.isEnabled = false
                case .authorized:
                    self?.permissionStatus = .authorized
                    self?.isEnabled = true
                case .provisional:
                    self?.permissionStatus = .provisional
                    self?.isEnabled = true
                case .ephemeral:
                    self?.permissionStatus = .authorized
                    self?.isEnabled = true
                @unknown default:
                    self?.permissionStatus = .notDetermined
                    self?.isEnabled = false
                }
            }
        }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.permissionStatus = .authorized
                    self?.isEnabled = true
                    UIApplication.shared.registerForRemoteNotifications()
                } else {
                    self?.permissionStatus = .denied
                    self?.isEnabled = false
                }
                completion(granted)
            }
        }
    }
    
    func openSystemSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
    
    func disableNotifications() {
        isEnabled = false
    }
}
