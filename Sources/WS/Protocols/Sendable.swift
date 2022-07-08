import Vapor
import NIOWebSocket

public protocol Sendable {
    @discardableResult
    func send<S>(text: S) -> EventLoopFuture<Void> where S: Collection, S.Element == Character
    @discardableResult
    func send(bytes: [UInt8]) -> EventLoopFuture<Void>
    @discardableResult
    func send<Data>(data: Data) -> EventLoopFuture<Void> where Data: DataProtocol
    @discardableResult
    func send<Data>(data: Data, opcode: WebSocketOpcode) -> EventLoopFuture<Void> where Data: DataProtocol
    @discardableResult
    func send<C>(model: C) -> EventLoopFuture<Void> where C: Encodable
    @discardableResult
    func send<C>(model: C, encoder: Encoder) -> EventLoopFuture<Void> where C: Encodable
    @discardableResult
    func send<T: Codable>(event: EventID<T>) -> EventLoopFuture<Void>
    @discardableResult
    func send<T: Codable>(event: EventID<T>, payload: T?) -> EventLoopFuture<Void>
    @discardableResult
    func sendPing() -> EventLoopFuture<Void>
}

internal protocol _Sendable: Sendable {
    var eventLoop: EventLoop { get }
    var exchangeMode: ExchangeMode { get }
    var logger: Logger { get }
    var _encoder: Encoder { get }
    var sockets: [WebSocket] { get }
}

extension _Sendable {
    func _send<S>(text: S) -> EventLoopFuture<Void> where S : Collection, S.Element == Character {
        /// Send as `binary` instead
        if exchangeMode == .binary {
            self.logger.warning("[⚡️] ❗️📤❗️text will be automatically converted to binary data. Observer is in `binary` mode.")
            return send(bytes: String(text).utf8.map{ UInt8($0) })
        }
        /// Send as `text`
        return eventLoop.future().map {
            self.sockets.forEach {
                self.logger.debug("[⚡️] 📤 text: \(text)")
                $0.send(text)
            }
        }
    }

    func _send(bytes: [UInt8]) -> EventLoopFuture<Void> {
        /// Send as `text` instead
        if exchangeMode == .text {
            self.logger.warning("[⚡️] ❗️📤❗️bytes will be automatically converted to text. Observer is in `binary` mode.")
            guard let text = String(bytes: bytes, encoding: .utf8) else {
                self.logger.warning("[⚡️] ❗️📤❗️Unable to convert bytes to text. Observer is in `binary` mode.")
                return eventLoop.future()
            }
            return send(text: text)
        }
        /// Send as `binary`
        return eventLoop.future().map {
            self.sockets.forEach {
                self.logger.debug("[⚡️] 📤 bytes: \(bytes.count)")
                $0.send(bytes)
            }
        }
    }

    func _send<Data>(data: Data) -> EventLoopFuture<Void> where Data : DataProtocol {
        send(data: data, opcode: .binary)
    }
    
    func _send<Data>(data: Data, opcode: WebSocketOpcode) -> EventLoopFuture<Void> where Data: DataProtocol {
        /// Send as `text` instead
        if exchangeMode == .text {
            self.logger.warning("[⚡️] ❗️📤❗️data will be automatically converted to text. Observer is in `text` mode.")
            guard let text = String(bytes: data, encoding: .utf8) else {
                self.logger.warning("[⚡️] ❗️📤❗️Unable to convert data to text. Observer is in `text` mode.")
                return eventLoop.future()
            }
            return send(text: text)
        }
        /// Send as `binary`
        return eventLoop.future().map {
            self.sockets.forEach {
                self.logger.debug("[⚡️] 📤 data: \(data.count)")
                $0.send(raw: data, opcode: opcode)
            }
        }
    }
    
    func _send<C>(model: C) -> EventLoopFuture<Void> where C: Encodable {
        send(model: model, encoder: _encoder)
    }
    
    func _send<C>(model: C, encoder: Encoder) -> EventLoopFuture<Void> where C: Encodable {
        eventLoop.future().flatMapThrowing {
            try encoder.encode(model)
        }.flatMap { data -> EventLoopFuture<Data> in
            if self.exchangeMode == .text {
                return self.eventLoop.future(data)
            }
            return self.send(data: data).transform(to: data)
        }.flatMap {
            guard self.exchangeMode != .binary,
                let text = String(data: $0, encoding: .utf8) else {
                return self.eventLoop.future()
            }
            return self.send(text: text)
        }
    }
    
    func _send<T: Codable>(event: EventID<T>) -> EventLoopFuture<Void> {
        send(event: event, payload: nil)
    }
    
    func _send<T: Codable>(event: EventID<T>, payload: T?) -> EventLoopFuture<Void> {
        send(model: Event(event: event.id, payload: payload))
    }
    
    func _sendPing() -> EventLoopFuture<Void> {
        eventLoop.future().map {
            self.sockets.forEach { $0.sendPing() }
        }
    }
}

// MARK: - EventLoopFuture

extension EventLoopFuture: Sendable where Value: Sendable {
    public func send<S>(text: S) -> EventLoopFuture<Void> where S : Collection, S.Element == Character {
        flatMap { $0.send(text: text) }
    }
    
    public func send(bytes: [UInt8]) -> EventLoopFuture<Void> {
        flatMap { $0.send(bytes: bytes) }
    }
    
    public func send<Data>(data: Data) -> EventLoopFuture<Void> where Data : DataProtocol {
        flatMap { $0.send(data: data) }
    }
    
    public func send<Data>(data: Data, opcode: WebSocketOpcode) -> EventLoopFuture<Void> where Data : DataProtocol {
        flatMap { $0.send(data: data, opcode: opcode) }
    }
    
    public func send<C>(model: C) -> EventLoopFuture<Void> where C : Encodable {
        flatMap { $0.send(model: model) }
    }
    
    public func send<C>(model: C, encoder: Encoder) -> EventLoopFuture<Void> where C : Encodable {
        flatMap { $0.send(model: model, encoder: encoder) }
    }
    
    public func send<T>(event: EventID<T>) -> EventLoopFuture<Void> where T : Decodable, T : Encodable {
        flatMap { $0.send(event: event) }
    }
    
    public func send<T>(event: EventID<T>, payload: T?) -> EventLoopFuture<Void> where T : Decodable, T : Encodable {
        flatMap { $0.send(event: event, payload: payload) }
    }
    
    public func sendPing() -> EventLoopFuture<Void> {
        flatMap { $0.sendPing() }
    }
}
