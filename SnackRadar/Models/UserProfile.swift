import Foundation
import FirebaseFirestore

struct UserProfile: Codable {
    let uid: String
    let email: String
    var userRole: UserRole
    var campusId: String?
    var pushToken: String?
    var createdAt: Date
    var isApproved: Bool
    var notificationsEnabled: Bool
    var roleUpgradeRequested: Bool
    var socialLinks: SocialLinks?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case userRole
        case campusId
        case pushToken
        case createdAt
        case isApproved
        case notificationsEnabled
        case roleUpgradeRequested
        case socialLinks
    }
    
    init(uid: String, email: String, userRole: UserRole, campusId: String? = nil, pushToken: String? = nil, createdAt: Date = Date(), isApproved: Bool = true, notificationsEnabled: Bool = false, roleUpgradeRequested: Bool = false, socialLinks: SocialLinks? = nil) {
        self.uid = uid
        self.email = email
        self.userRole = userRole
        self.campusId = campusId
        self.pushToken = pushToken
        self.createdAt = createdAt
        self.isApproved = userRole == .student ? true : false
        self.notificationsEnabled = notificationsEnabled
        self.roleUpgradeRequested = roleUpgradeRequested
        self.socialLinks = socialLinks
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uid = try container.decode(String.self, forKey: .uid)
        email = try container.decode(String.self, forKey: .email)
        userRole = try container.decode(UserRole.self, forKey: .userRole)
        campusId = try container.decodeIfPresent(String.self, forKey: .campusId)
        pushToken = try container.decodeIfPresent(String.self, forKey: .pushToken)
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
        
        isApproved = try container.decodeIfPresent(Bool.self, forKey: .isApproved) ?? true
        notificationsEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationsEnabled) ?? false
        roleUpgradeRequested = try container.decodeIfPresent(Bool.self, forKey: .roleUpgradeRequested) ?? false
        socialLinks = try container.decodeIfPresent(SocialLinks.self, forKey: .socialLinks)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uid, forKey: .uid)
        try container.encode(email, forKey: .email)
        try container.encode(userRole, forKey: .userRole)
        try container.encodeIfPresent(campusId, forKey: .campusId)
        try container.encodeIfPresent(pushToken, forKey: .pushToken)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(isApproved, forKey: .isApproved)
        try container.encode(notificationsEnabled, forKey: .notificationsEnabled)
        try container.encode(roleUpgradeRequested, forKey: .roleUpgradeRequested)
        try container.encodeIfPresent(socialLinks, forKey: .socialLinks)
    }
    
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "uid": uid,
            "email": email,
            "userRole": userRole.rawValue,
            "createdAt": Timestamp(date: createdAt),
            "isApproved": isApproved,
            "notificationsEnabled": notificationsEnabled,
            "roleUpgradeRequested": roleUpgradeRequested
        ]
        
        if let campusId = campusId {
            dict["campusId"] = campusId
        }
        
        if let pushToken = pushToken {
            dict["pushToken"] = pushToken
        }
        
        if let socialLinks = socialLinks {
            if let socialLinksData = try? JSONEncoder().encode(socialLinks),
               let socialLinksDict = try? JSONSerialization.jsonObject(with: socialLinksData) as? [String: Any] {
                dict["socialLinks"] = socialLinksDict
            }
        }
        
        return dict
    }
}
