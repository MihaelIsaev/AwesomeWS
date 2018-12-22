import Foundation
import Vapor
import WebSocket

public class WSClient {
    public let cid = UUID()
    
    let connection: WebSocket
    public let req: Request
    public let eventLoop: EventLoop
    public var channels = Set<String>()
    
    weak var logger: WSLoggable?
    weak var broadcastable: WSBroadcastable?
    func broadcaster() throws -> WSBroadcastable {
        guard let broadcastable = broadcastable else {
            throw WSError(reason: "Unable to unwrap broadcastable")
        }
        return broadcastable
    }
    
    init (_ connection: WebSocket, _ req: Request, ws: (WSLoggable & WSBroadcastable)) {
        self.connection = connection
        self.req = req
        self.eventLoop = req.eventLoop
        self.logger = ws
        self.broadcastable = ws
    }
}

extension WSClient: Hashable, Equatable {
    public static func == (lhs: WSClient, rhs: WSClient) -> Bool {
        return lhs.cid == rhs.cid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(cid)
    }
}

extension WSClient {
    /// Sends text-formatted data to the connected client.
    @discardableResult
    public func emit<S>(_ text: S) -> Future<Void> where S: Collection, S.Element == Character {
        let promise = eventLoop.newPromise(of: Void.self)
        connection.send(text, promise: promise)
        return promise.futureResult
    }
    
    /// Sends binary-formatted data to the connected client.
    @discardableResult
    public func emit(_ binary: Data) -> Future<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        connection.send(binary: binary, promise: promise)
        return promise.futureResult
    }
    
    /// Sends text-formatted data to the connected client.
    @discardableResult
    public func emit(text: LosslessDataConvertible) -> Future<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        connection.send(text: text, promise: promise)
        return promise.futureResult
    }
    
    /// Sends binary-formatted data to the connected client.
    @discardableResult
    public func emit(binary: LosslessDataConvertible) -> Future<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        connection.send(binary: binary, promise: promise)
        return promise.futureResult
    }
    
    /// Sends raw-data to the connected client using the supplied WebSocket opcode.
    @discardableResult
    public func emit(raw data: LosslessDataConvertible, opcode: WebSocketOpcode, fin: Bool = true) -> Future<Void> {
        let promise = eventLoop.newPromise(of: Void.self)
        connection.send(raw: data, opcode: opcode, fin: fin, promise: promise)
        return promise.futureResult
    }
    
    /// Sends Codable model encoded to JSON string
    @discardableResult
    public func emit<T: Codable>(asText event: WSEventIdentifier<T>, payload: T? = nil) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            logger?.log(.error("Unable to preapare JSON string emit"))
            throw WSError(reason: "Unable to preapare JSON string emit")
        }
        return emit(jsonString)
    }
    
    /// Sends Codable model encoded to JSON binary
    @discardableResult
    public func emit<T: Codable>(asBinary event: WSEventIdentifier<T>, payload: T? = nil) throws -> Future<Void> {
        return emit(try JSONEncoder().encode(event))
    }
}
