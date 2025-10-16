import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.shared.handleAPNsToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        print("Received remote notification: \(userInfo)")
        
        if let eventId = userInfo["eventId"] as? String {
            NotificationCenter.default.post(name: .didReceiveEventNotification, object: nil, userInfo: ["eventId": eventId])
            return .newData
        }
        
        return .noData
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Will present notification: \(userInfo)")
        
        if let eventId = userInfo["eventId"] as? String {
            NotificationCenter.default.post(name: .didReceiveEventNotification, object: nil, userInfo: ["eventId": eventId, "foreground": true])
        }
        
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushNotificationManager.shared.handleNotificationResponse(response, completion: completionHandler)
    }
}
