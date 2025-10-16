import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    let uid: String
    let email: String
    var userRole: UserRole
    var campusId: String?
    var pushToken: String?
    var pushNotificationsEnabled: Bool
    var createdAt: Date
    var isApproved: Bool
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case userRole
        case campusId
        case pushToken
        case pushNotificationsEnabled
        case createdAt
        case isApproved
    }
    
    init(uid: String, email: String, userRole: UserRole, campusId: String? = nil, pushToken: String? = nil, pushNotificationsEnabled: Bool = false, createdAt: Date = Date(), isApproved: Bool = true) {
        self.uid = uid
        self.email = email
        self.userRole = userRole
        self.campusId = campusId
        self.pushToken = pushToken
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.createdAt = createdAt
        self.isApproved = userRole == .student ? true : false
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        email = try container.decode(String.self, forKey: .email)
        userRole = try container.decode(UserRole.self, forKey: .userRole)
        campusId = try container.decodeIfPresent(String.self, forKey: .campusId)
        pushToken = try container.decodeIfPresent(String.self, forKey: .pushToken)
        pushNotificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .pushNotificationsEnabled) ?? false
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
        
        isApproved = try container.decodeIfPresent(Bool.self, forKey: .isApproved) ?? true
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(email, forKey: .email)
        try container.encode(userRole, forKey: .userRole)
        try container.encodeIfPresent(campusId, forKey: .campusId)
        try container.encodeIfPresent(pushToken, forKey: .pushToken)
        try container.encode(pushNotificationsEnabled, forKey: .pushNotificationsEnabled)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(isApproved, forKey: .isApproved)
    }
    
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "uid": uid,
            "email": email,
            "userRole": userRole.rawValue,
            "pushNotificationsEnabled": pushNotificationsEnabled,
            "createdAt": Timestamp(date: createdAt),
            "isApproved": isApproved
        ]
        
        if let campusId = campusId {
            dict["campusId"] = campusId
        }
        
        if let pushToken = pushToken {
            dict["pushToken"] = pushToken
        }
        
        return dict
    }
}
