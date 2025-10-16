import Foundation
import FirebaseFirestore

struct PromoPost: Codable, Identifiable {
    let id: String
    var title: String
    var content: String
    var imageUrl: String?
    var campusId: String
    var organizerId: String
    var organizerName: String
    var isApproved: Bool
    var isPinned: Bool
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case imageUrl
        case campusId
        case organizerId
        case organizerName
        case isApproved
        case isPinned
        case createdAt
        case updatedAt
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        imageUrl: String? = nil,
        campusId: String,
        organizerId: String,
        organizerName: String,
        isApproved: Bool = false,
        isPinned: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.imageUrl = imageUrl
        self.campusId = campusId
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.isApproved = isApproved
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        campusId = try container.decode(String.self, forKey: .campusId)
        organizerId = try container.decode(String.self, forKey: .organizerId)
        organizerName = try container.decode(String.self, forKey: .organizerName)
        isApproved = try container.decodeIfPresent(Bool.self, forKey: .isApproved) ?? false
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .updatedAt) {
            updatedAt = timestamp.dateValue()
        } else {
            updatedAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encode(campusId, forKey: .campusId)
        try container.encode(organizerId, forKey: .organizerId)
        try container.encode(organizerName, forKey: .organizerName)
        try container.encode(isApproved, forKey: .isApproved)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(Timestamp(date: updatedAt), forKey: .updatedAt)
    }
    
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "content": content,
            "campusId": campusId,
            "organizerId": organizerId,
            "organizerName": organizerName,
            "isApproved": isApproved,
            "isPinned": isPinned,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
        
        if let imageUrl = imageUrl {
            dict["imageUrl"] = imageUrl
        }
        
        return dict
    }
}
