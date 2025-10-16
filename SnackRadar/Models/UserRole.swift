import Foundation

enum UserRole: String, Codable {
    case student
    case organizer
    
    var displayName: String {
        switch self {
        case .student:
            return "Student"
        case .organizer:
            return "Organizer"
        }
    }
}
