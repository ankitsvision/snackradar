import Foundation

enum EventStatus: String, Codable {
    case upcoming
    case live
    case expired
    
    var displayName: String {
        switch self {
        case .upcoming:
            return "Upcoming"
        case .live:
            return "Live"
        case .expired:
            return "Expired"
        }
    }
    
    static func calculate(startTime: Date, endTime: Date, now: Date = Date()) -> EventStatus {
        if now < startTime {
            return .upcoming
        } else if now >= startTime && now <= endTime {
            return .live
        } else {
            return .expired
        }
    }
}
