import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging

class FirebaseService {
    static let shared = FirebaseService()
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    let messaging: Messaging
    
    private init() {
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        self.messaging = Messaging.messaging()
        
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        firestore.settings = settings
    }
    
    func configureMessaging(delegate: MessagingDelegate) {
        messaging.delegate = delegate
    }
    
    func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
