import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseAuth

enum NotificationPermissionStatus {
    case notDetermined
    case authorized
    case denied
}

class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()
    
    @Published var permissionStatus: NotificationPermissionStatus = .notDetermined
    @Published var fcmToken: String?
    
    private let userRepository = UserRepository.shared
    private var apnsToken: String?
    
    private override init() {
        super.init()
        Messaging.messaging().delegate = self
        checkPermissionStatus()
    }
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.permissionStatus = granted ? .authorized : .denied
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("Error requesting notification permission: \(error.localizedDescription)")
            await MainActor.run {
                self.permissionStatus = .denied
            }
            return false
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    self.permissionStatus = .authorized
                case .denied:
                    self.permissionStatus = .denied
                case .notDetermined:
                    self.permissionStatus = .notDetermined
                default:
                    self.permissionStatus = .notDetermined
                }
            }
        }
    }
    
    @MainActor
    func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func handleAPNsToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.apnsToken = token
        
        Messaging.messaging().apnsToken = deviceToken
        
        print("APNs device token: \(token)")
    }
    
    func updatePushToken(for userId: String) async throws {
        guard let fcmToken = fcmToken else {
            throw NSError(domain: "PushNotificationManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "FCM token not available"])
        }
        
        try await userRepository.updatePushToken(uid: userId, token: fcmToken)
    }
    
    func removePushToken(for userId: String) async throws {
        try await userRepository.removePushToken(uid: userId)
    }
    
    func scheduleLocalNotification(title: String, body: String, eventId: String? = nil, delay: TimeInterval = 0) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        if let eventId = eventId {
            content.userInfo = ["eventId": eventId, "type": "event"]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 1), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error.localizedDescription)")
            }
        }
    }
    
    func broadcastEventNotification(event: Event, campusId: String) async throws {
        guard let cloudFunctionURL = Bundle.main.object(forInfoDictionaryKey: "CLOUD_FUNCTION_URL") as? String else {
            print("Cloud Function URL not configured")
            return
        }
        
        guard let url = URL(string: "\(cloudFunctionURL)/broadcastEventNotification") else {
            throw NSError(domain: "PushNotificationManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let payload: [String: Any] = [
            "eventId": event.id,
            "title": event.title,
            "body": event.description,
            "campusId": campusId,
            "startTime": ISO8601DateFormatter().string(from: event.startTime),
            "location": event.location
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let user = Auth.auth().currentUser {
            let token = try await user.getIDToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "PushNotificationManager", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to broadcast notification"])
        }
        
        print("Successfully broadcasted event notification: \(String(data: data, encoding: .utf8) ?? "")")
    }
    
    func handleNotificationResponse(_ response: UNNotificationResponse, completion: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let eventId = userInfo["eventId"] as? String,
           let type = userInfo["type"] as? String,
           type == "event" {
            NotificationCenter.default.post(name: .didReceiveEventNotification, object: nil, userInfo: ["eventId": eventId])
        }
        
        completion()
    }
    
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

extension PushNotificationManager: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM registration token: \(fcmToken ?? "nil")")
        
        DispatchQueue.main.async {
            self.fcmToken = fcmToken
        }
        
        if let userId = Auth.auth().currentUser?.uid, let token = fcmToken {
            Task {
                do {
                    try await self.userRepository.updatePushToken(uid: userId, token: token)
                    print("Successfully updated FCM token in Firestore")
                } catch {
                    print("Error updating FCM token: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension Notification.Name {
    static let didReceiveEventNotification = Notification.Name("didReceiveEventNotification")
}
