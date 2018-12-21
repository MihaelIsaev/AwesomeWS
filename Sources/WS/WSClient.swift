import Foundation
import Vapor
import WebSocket

protocol WSClientDelegate: class {
    func onTextHandler(_ client: WSClient, text: String)
    func onBinaryHandler(_ client: WSClient, data: Data)
    func onErrorHandler(_ client: WSClient, error: Error)
    func onCloseHandler()
}

public class WSClient {
    public let uid = UUID()
    
    let connection: WebSocket
    public let eventLoop: EventLoop
    public var channels = Set<String>()
    
    weak var delegate: WSClientDelegate?
    
    typealias JoinedChannelHandler = (String) -> Void
    typealias LeftChannelHandler = (String) -> Void
    
    init (_ connection: WebSocket, _ req: Request, delegate: WSClientDelegate? = nil) {
        self.connection = connection
        self.eventLoop = req.eventLoop
        self.delegate = delegate
        connection.onText { [weak self] _, text in
            guard let self = self else { return }
            self.delegate?.onTextHandler(self, text: text)
        }
        connection.onBinary { [weak self] _, data in
            guard let self = self else { return }
            self.delegate?.onBinaryHandler(self, data: data)
        }
        connection.onError { [weak self] _, error in
            guard let self = self else { return }
            self.delegate?.onErrorHandler(self, error: error)
        }
        connection.onClose.always {
            self.delegate?.onCloseHandler()
        }
    }
}

extension WSClient {
    /// Sends text-formatted data to the connected client.
    public func send<S>(_ text: S, promise: Promise<Void>? = nil) where S: Collection, S.Element == Character {
        return connection.send(text, promise: promise)
    }
    
    /// Sends binary-formatted data to the connected client.
    public func send(_ binary: Data, promise: Promise<Void>? = nil) {
        return connection.send(binary: binary, promise: promise)
    }
    
    /// Sends text-formatted data to the connected client.
    public func send(text: LosslessDataConvertible, promise: Promise<Void>? = nil) {
        connection.send(text: text, promise: promise)
    }
    
    /// Sends binary-formatted data to the connected client.
    public func send(binary: LosslessDataConvertible, promise: Promise<Void>? = nil) {
        connection.send(binary: binary, promise: promise)
    }
    
    /// Sends raw-data to the connected client using the supplied WebSocket opcode.
    public func send(raw data: LosslessDataConvertible, opcode: WebSocketOpcode, fin: Bool = true, promise: Promise<Void>? = nil) {
        connection.send(raw: data, opcode: opcode, fin: fin, promise: promise)
    }
}
