import Foundation

struct Event<P: Codable>: Codable {
    public let event: String
    public let payload: P?
    public init (event: String, payload: P? = nil) {
        self.event = event
        self.payload = payload
    }
}

struct EventPrototype: Codable {
    public var event: String
}
