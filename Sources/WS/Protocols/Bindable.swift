import Foundation
import NIO

typealias BindHandler = (AnyClient, Data) -> Void

public protocol Bindable: AnyObserver {
    /// Binds to event without payload
    ///
    /// - parameters:
    ///     - identifier: `EID` event identifier, declare it in extension
    ///     - handler: called when event happens
    func bind<P>(_ identifier: EID<P>, _ handler: @escaping (AnyClient) -> Void) where P: Codable
    
    /// Binds to event with optional payload
    ///
    /// - parameters:
    ///     - identifier: `EID` event identifier, declare it in extension
    ///     - handler: called when event happens
    func bindOptional<P>(_ identifier: EID<P>, _ handler: @escaping (AnyClient, P?) -> Void) where P: Codable
    
    /// Binds to event with required payload
    /// 
    /// - parameters:
    ///     - identifier: `EID` event identifier, declare it in extension
    ///     - handler: called when event happens
    func bind<P>(_ identifier: EID<P>, _ handler: @escaping (AnyClient, P) -> Void) where P: Codable
}

internal protocol _Bindable: Bindable, _AnyObserver {
    var binds: [String: BindHandler] { get set }
}

extension _Bindable {
    func _bind<P: Codable>(_ identifier: EID<P>, _ handler: @escaping (AnyClient) -> Void) {
        bindOptional(identifier) { client, _ in
            handler(client)
        }
    }
    
    func _bindOptional<P: Codable>(_ identifier: EID<P>, _ handler: @escaping (AnyClient, P?) -> Void) {
        binds[identifier.id] = { client, data in
            do {
                let res = try self._decoder.decode(Event<P>.self, from: data)
                handler(client, res.payload)
            } catch {
                self.unableToDecode(identifier.id, error)
            }
        }
    }

    func _bind<P: Codable>(_ identifier: EID<P>, _ handler: @escaping (AnyClient, P) -> Void) {
        binds[identifier.id] = { client, data in
            do {
                let res = try self._decoder.decode(Event<P>.self, from: data)
                if let payload = res.payload {
                    handler(client, payload)
                } else {
                    self.logger.warning("[⚡️] ❗️📥❗️Unable to unwrap payload for event `\(identifier.id)`, because it is unexpectedly nil. Please use another `bind` method which support optional payload to avoid this message.")
                }
            } catch {
                self.unableToDecode(identifier.id, error)
            }
        }
    }
    
    private func unableToDecode(_ id: String, _ error: Error) {
        switch logger.logLevel {
        case .debug: logger.debug("[⚡️] ❗️📥❗️Undecodable incoming event `\(id)`: \(error)")
        default: logger.error("[⚡️] ❗️📥❗️Unable to decode incoming event `\(id)`")
        }
    }
}

extension _Bindable {
    func _on(text: String, client: _AnyClient) {
        if let data = text.data(using: .utf8) {
            proceedData(client, data)
        }
    }
    
    func _on(byteBuffer: ByteBuffer, client: _AnyClient) {
        guard byteBuffer.readableBytes > 0 else { return }
        var bytes: [UInt8] = byteBuffer.getBytes(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes) ?? []
        let data = Data(bytes: &bytes, count: byteBuffer.readableBytes)
        proceedData(client, data)
    }
    
    func _on(data: Data, client: _AnyClient) {
        proceedData(client, data)
    }

    private func proceedData(_ client: _AnyClient, _ data: Data) {
        do {
            let prototype = try _decoder.decode(EventPrototype.self, from: data)
            if let bind = binds.first(where: { $0.0 == prototype.event }) {
                bind.value(client, data)
            }
        } catch {
            unableToDecode(error)
        }
    }
    
    private func unableToDecode(_ error: Error) {
        switch logger.logLevel {
        case .debug: logger.debug("[⚡️] ❗️📥❗️Unable to decode incoming event cause it doesn't conform to `EventPrototype` model: \(error)")
        default: logger.error("[⚡️] ❗️📥❗️Unable to decode incoming event cause it doesn't conform to `EventPrototype` model")
        }
    }
}
