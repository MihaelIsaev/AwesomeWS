import Vapor
import WebSocket
import Foundation

protocol WSErrorProtocol: Error {}
public struct WSError: WSErrorProtocol {
    public var reason: String
    init(reason: String) {
        self.reason = reason
    }
}

// MARK: Engine

open class WS: Service, WebSocketServer {
    var server = NIOWebSocketServer.default()
    var clients: [WSClient] = []
    //var acks: [UUID]
    
    public struct NotificationMessage: Codable {
        var type: String
        var data: Data?
        public init<T: RawRepresentable>(_ type: T, data: Data? = nil) where T.RawValue == String {
            self.type = type.rawValue
            self.data = data
        }
    }
    
    public typealias WSHTTPConnectionHandler = (Request) throws -> Void
    public typealias WSHTTPConnectionFutureHandler = (Request) throws -> Future<Void>
    
    // MARK: Initialization
    
    public init(at path: [PathComponent], handler: WSHTTPConnectionFutureHandler? = nil) {
        server.get(at: path) { (ws, req) in
            do {
                if let handler = handler {
                    _ = try handler(req).map {
                        try self.onConnection(ws, req)
                    }
                } else {
                    try self.onConnection(ws, req)
                }
            } catch {
                ws.close(code: .policyViolation)
            }
        }
    }
    
    convenience init(at path: [PathComponent], handler: @escaping WSHTTPConnectionHandler) {
        self.init(at: path) { req -> Future<Void> in
            try handler(req)
            return req.eventLoop.newSucceededFuture(result: ())
        }
    }
    
    public convenience init(at path: PathComponent..., handler: @escaping WSHTTPConnectionHandler) {
        self.init(at: path, handler: handler)
    }
    
    public convenience init(at path: PathComponentsRepresentable..., handler: @escaping WSHTTPConnectionHandler) {
        self.init(at: path.convertToPathComponents(), handler: handler)
    }
    
    public convenience init(at path: PathComponent..., handler: WSHTTPConnectionFutureHandler? = nil) {
        self.init(at: path, handler: handler)
    }
    
    public convenience init(at path: PathComponentsRepresentable..., handler: WSHTTPConnectionFutureHandler? = nil) {
        self.init(at: path.convertToPathComponents(), handler: handler)
    }
    
    //MARK: Text
    
    public func broadcast(_ text: String) throws {
        try broadcast(clients, text)
    }
    
    public func broadcast(room: String, _ text: String) throws {
        try broadcast(clients.filter { $0.rooms.contains(room) }, text)
    }
    
    public func broadcast(_ clients: [WSClient], _ text: String) throws {
        clients.forEach { $0.connection.send(text) }
    }
    
    //MARK: JSON
    
    public func broadcast<T: Codable>(_ jsonPayload: T) throws {
        try broadcast(clients, jsonPayload)
    }
    
    public func broadcast<T: Codable>(room: String, _ jsonPayload: T) throws {
        try broadcast(clients.filter { $0.rooms.contains(room) }, jsonPayload)
    }
    
    public func broadcast<T: Codable>(_ clients: [WSClient], _ jsonPayload: T) throws {
        let jsonData = try JSONEncoder().encode(jsonPayload)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        clients.forEach { $0.connection.send(jsonString) }
    }
    
    //MARK: Binary
    
    public func broadcast(_ binary: Data) throws {
        try broadcast(clients, binary)
    }
    
    public func broadcast(room: String, _ binary: Data) throws {
        try broadcast(clients.filter { $0.rooms.contains(room) }, binary)
    }
    
    public func broadcast(_ clients: [WSClient], _ binary: Data) throws {
        clients.forEach { $0.connection.send(binary) }
    }
    
    //MARK: - WebSocketServer
    
    public func webSocketShouldUpgrade(for request: Request) -> HTTPHeaders? {
        return server.webSocketShouldUpgrade(for: request)
    }
    
    public func webSocketOnUpgrade(_ webSocket: WebSocket, for request: Request) {
        server.webSocketOnUpgrade(webSocket, for: request)
    }
}
