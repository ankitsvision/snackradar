import Foundation

struct DateFormatters {
    static let shared = DateFormatters()
    
    private init() {}
    
    let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let displayTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    let displayDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter
    }()
    
    let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension Date {
    func formatted(style: DateFormatter) -> String {
        return style.string(from: self)
    }
    
    var displayDate: String {
        DateFormatters.shared.displayDate.string(from: self)
    }
    
    var displayTime: String {
        DateFormatters.shared.displayTime.string(from: self)
    }
    
    var displayDateTime: String {
        DateFormatters.shared.displayDateTime.string(from: self)
    }
    
    var shortDate: String {
        DateFormatters.shared.shortDate.string(from: self)
    }
    
    var shortDateTime: String {
        DateFormatters.shared.shortDateTime.string(from: self)
    }
}
