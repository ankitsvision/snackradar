import Foundation
import FirebaseFirestore

struct Event: Codable, Identifiable {
    let id: String
    var title: String
    var description: String
    var campusId: String
    var organizerId: String
    var organizerName: String
    var location: String
    var startTime: Date
    var endTime: Date
    var imageUrl: String?
    var isApproved: Bool
    var createdAt: Date
    var updatedAt: Date
    
    var status: EventStatus {
        EventStatus.calculate(startTime: startTime, endTime: endTime)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case campusId
        case organizerId
        case organizerName
        case location
        case startTime
        case endTime
        case imageUrl
        case isApproved
        case createdAt
        case updatedAt
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        campusId: String,
        organizerId: String,
        organizerName: String,
        location: String,
        startTime: Date,
        endTime: Date,
        imageUrl: String? = nil,
        isApproved: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.campusId = campusId
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.location = location
        self.startTime = startTime
        self.endTime = endTime
        self.imageUrl = imageUrl
        self.isApproved = isApproved
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        campusId = try container.decode(String.self, forKey: .campusId)
        organizerId = try container.decode(String.self, forKey: .organizerId)
        organizerName = try container.decode(String.self, forKey: .organizerName)
        location = try container.decode(String.self, forKey: .location)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        isApproved = try container.decodeIfPresent(Bool.self, forKey: .isApproved) ?? false
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .startTime) {
            startTime = timestamp.dateValue()
        } else {
            startTime = Date()
        }
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .endTime) {
            endTime = timestamp.dateValue()
        } else {
            endTime = Date()
        }
        
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
        try container.encode(description, forKey: .description)
        try container.encode(campusId, forKey: .campusId)
        try container.encode(organizerId, forKey: .organizerId)
        try container.encode(organizerName, forKey: .organizerName)
        try container.encode(location, forKey: .location)
        try container.encode(Timestamp(date: startTime), forKey: .startTime)
        try container.encode(Timestamp(date: endTime), forKey: .endTime)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encode(isApproved, forKey: .isApproved)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
        try container.encode(Timestamp(date: updatedAt), forKey: .updatedAt)
    }
    
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "campusId": campusId,
            "organizerId": organizerId,
            "organizerName": organizerName,
            "location": location,
            "startTime": Timestamp(date: startTime),
            "endTime": Timestamp(date: endTime),
            "isApproved": isApproved,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
        
        if let imageUrl = imageUrl {
            dict["imageUrl"] = imageUrl
        }
        
        return dict
    }
}
