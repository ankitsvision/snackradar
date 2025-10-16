import Foundation

struct SocialLinks: Codable {
    var instagram: String?
    var twitter: String?
    var facebook: String?
    var linkedIn: String?
    var website: String?
    
    var isEmpty: Bool {
        return instagram == nil && twitter == nil && facebook == nil && linkedIn == nil && website == nil
    }
}
