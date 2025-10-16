import Foundation

enum FoodType: String, Codable, CaseIterable, Identifiable {
    case pizza
    case sandwiches
    case salads
    case desserts
    case beverages
    case snacks
    case breakfast
    case lunch
    case dinner
    case other
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pizza:
            return "Pizza"
        case .sandwiches:
            return "Sandwiches"
        case .salads:
            return "Salads"
        case .desserts:
            return "Desserts"
        case .beverages:
            return "Beverages"
        case .snacks:
            return "Snacks"
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .other:
            return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .pizza:
            return "🍕"
        case .sandwiches:
            return "🥪"
        case .salads:
            return "🥗"
        case .desserts:
            return "🍰"
        case .beverages:
            return "🥤"
        case .snacks:
            return "🍿"
        case .breakfast:
            return "🥐"
        case .lunch:
            return "🍱"
        case .dinner:
            return "🍽️"
        case .other:
            return "🍴"
        }
    }
}
