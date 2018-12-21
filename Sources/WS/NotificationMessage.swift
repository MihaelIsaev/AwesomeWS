import Foundation

public struct NotificationMessage: Codable {
    var type: String
    var data: Data?
    public init<T: RawRepresentable>(_ type: T, data: Data? = nil) where T.RawValue == String {
        self.type = type.rawValue
        self.data = data
    }
}
