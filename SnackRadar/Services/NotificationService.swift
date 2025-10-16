import Foundation
import FirebaseMessaging

enum NotificationType {
    case newEvent
    case eventUpdate
    case eventReminder
    case newPromo
}

struct NotificationPayload {
    let title: String
    let body: String
    let campusId: String
    let data: [String: Any]?
}

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func scheduleEventNotification(for event: Event) async {
        let payload = NotificationPayload(
            title: "New Event: \(event.title)",
            body: "\(event.foodType.icon) \(event.description)",
            campusId: event.campusId,
            data: [
                "eventId": event.id,
                "type": "new_event"
            ]
        )
        
        await sendCampusNotification(payload: payload)
    }
    
    func scheduleEventUpdateNotification(for event: Event) async {
        let payload = NotificationPayload(
            title: "Event Updated: \(event.title)",
            body: "An event has been updated. Check it out!",
            campusId: event.campusId,
            data: [
                "eventId": event.id,
                "type": "event_update"
            ]
        )
        
        await sendCampusNotification(payload: payload)
    }
    
    private func sendCampusNotification(payload: NotificationPayload) async {
        print("📱 [NotificationService] Scheduling notification for campus: \(payload.campusId)")
        print("   Title: \(payload.title)")
        print("   Body: \(payload.body)")
    }
    
    func subscribeToCampus(_ campusId: String) {
        let topic = "campus_\(campusId)"
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("❌ Failed to subscribe to topic \(topic): \(error.localizedDescription)")
            } else {
                print("✅ Successfully subscribed to topic: \(topic)")
            }
        }
    }
    
    func unsubscribeFromCampus(_ campusId: String) {
        let topic = "campus_\(campusId)"
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("❌ Failed to unsubscribe from topic \(topic): \(error.localizedDescription)")
            } else {
                print("✅ Successfully unsubscribed from topic: \(topic)")
            }
        }
    }
}
