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

private struct NextResponder: Responder {
    typealias NextCallback = () throws -> ()
    
    let next: NextCallback
    
    init(next: @escaping NextCallback) {
        self.next = next
    }
    
    func respond(to req: Request) throws -> Future<Response> {
        try next()
        let resp = Response(http: HTTPResponse(status: .ok,
                                                                    version: HTTPVersion.init(major: 1, minor: 1),
                                                                    headers: HTTPHeaders(),
                                                                    body: ""), using: req)
        return req.eventLoop.newSucceededFuture(result: resp)
    }
}

open class WS: Service, WebSocketServer {
    var server = NIOWebSocketServer.default()
    var clients: [WSClient] = []
    var middlewares: [Middleware] = []
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
    
    public init(at path: [PathComponent], protectedBy middlewares: [Middleware]? = nil) {
        self.middlewares = middlewares ?? []
        server.get(at: path) { (ws, req) in
            do {
                try self.onConnection(ws, req)
            } catch {
                ws.close(code: .policyViolation)
            }
        }
    }
    
    public convenience init(at path: PathComponent..., protectedBy middlewares: [Middleware]? = nil) {
        self.init(at: path, protectedBy: middlewares)
    }
    
    public convenience init(at path: PathComponentsRepresentable..., protectedBy middlewares: [Middleware]? = nil) {
        self.init(at: path.convertToPathComponents(), protectedBy: middlewares)
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
}
    //MARK: - WebSocketServer

extension WS {
    public func webSocketShouldUpgrade(for request: Request) -> HTTPHeaders? {
        return server.webSocketShouldUpgrade(for: request)
    }
    
    public func webSocketOnUpgrade(_ webSocket: WebSocket, for request: Request) {
        let success: () throws -> Void = {
            self.server.webSocketOnUpgrade(webSocket, for: request)
        }
        do {
            var middlewares = self.middlewares
            if middlewares.count == 0 {
                try success()
            } else {
                var iterate: () throws -> Void = {}
                iterate = {
                    if let middleware = middlewares.first {
                        middlewares.removeFirst()
                        let nextResponder = NextResponder(next: iterate)
                        _ = try middleware.respond(to: request, chainingTo: nextResponder)
                    } else {
                        try success()
                    }
                }
                try iterate()
            }
        } catch {
            webSocket.close(code: .policyViolation)
        }
    }
}
