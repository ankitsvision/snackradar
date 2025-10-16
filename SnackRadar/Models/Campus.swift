import Foundation
import FirebaseFirestore

struct Campus: Codable, Identifiable {
    let id: String
    var name: String
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var latitude: Double?
    var longitude: Double?
    var isActive: Bool
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case city
        case state
        case zipCode
        case latitude
        case longitude
        case isActive
        case createdAt
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        city: String,
        state: String,
        zipCode: String,
        latitude: Double? = nil,
        longitude: Double? = nil,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.isActive = isActive
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        city = try container.decode(String.self, forKey: .city)
        state = try container.decode(String.self, forKey: .state)
        zipCode = try container.decode(String.self, forKey: .zipCode)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        
        if let timestamp = try? container.decode(Timestamp.self, forKey: .createdAt) {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(city, forKey: .city)
        try container.encode(state, forKey: .state)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(Timestamp(date: createdAt), forKey: .createdAt)
    }
    
    var asDictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "address": address,
            "city": city,
            "state": state,
            "zipCode": zipCode,
            "isActive": isActive,
            "createdAt": Timestamp(date: createdAt)
        ]
        
        if let latitude = latitude {
            dict["latitude"] = latitude
        }
        
        if let longitude = longitude {
            dict["longitude"] = longitude
        }
        
        return dict
    }
    
    var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }
}
