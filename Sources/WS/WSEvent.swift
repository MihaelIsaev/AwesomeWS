import Foundation

public struct NoPayload: Codable {}

public struct WSEvent<P: Codable>: Codable {
    public let event: String
    public let payload: P?
    public init (event: String, payload: P? = nil) {
        self.event = event
        self.payload = payload
    }
}

public struct WSEventPrototype: Codable {
    public var event: String
}

public struct WSOutgoingEvent<P: Codable>: Codable {
    var event: String
    var payload: P?
    init(_ event: String, payload: P?) {
        self.event = event
        self.payload = payload
    }
}
