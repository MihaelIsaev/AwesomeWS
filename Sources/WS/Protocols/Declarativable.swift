import Vapor

public typealias EmptyHandler = () -> Void
public typealias OpenCloseHandler = (AnyClient) -> Void
public typealias TextHandler = (AnyClient, String) -> Void
public typealias ByteBufferHandler = (AnyClient, ByteBuffer) -> Void
public typealias BinaryHandler = (AnyClient, Data) -> Void

public class DeclarativeHandlers {
    var openHander: OpenCloseHandler?
    var closeHander: OpenCloseHandler?
    var pingHander: OpenCloseHandler?
    var pongHander: OpenCloseHandler?
    var textHander: TextHandler?
    var byteBufferHander: ByteBufferHandler?
    var binaryHander: BinaryHandler?
}

public protocol Declarativable: AnyObserver {
    var handlers: DeclarativeHandlers { get }
}

internal protocol _Declarativable: Declarativable, _AnyObserver {
    var handlers: DeclarativeHandlers { get set }
}

extension _Declarativable {
    func _on(open client: _AnyClient) {
        handlers.openHander?(client)
    }
    
    func _on(close client: _AnyClient) {
        handlers.closeHander?(client)
    }
    
    func _on(ping client: _AnyClient) {
        handlers.pingHander?(client)
    }
    
    func _on(pong client: _AnyClient) {
        handlers.pongHander?(client)
    }
    
    func _on(text: String, client: _AnyClient) {
        guard let handler = handlers.textHander else {
            logger.warning("[⚡️] ❗️📥❗️ \(description) received `text` but handler is nil")
            return
        }
        handler(client, text)
    }
    
    func _on(byteBuffer: ByteBuffer, client: _AnyClient) {
        guard let handler = handlers.byteBufferHander else {
            logger.warning("[⚡️] ❗️📥❗️ \(description) received `byteBuffer` but handler is nil")
            return
        }
        handler(client, byteBuffer)
    }
    
    func _on(data: Data, client: _AnyClient) {
        guard let handler = handlers.binaryHander else {
            logger.warning("[⚡️] ❗️📥❗️ \(description) received `binary data` but handler is nil")
            return
        }
        handler(client, data)
    }
}

extension Declarativable {
    @discardableResult
     public func onOpen(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.openHander = handler
         return self
     }
     
     @discardableResult
     public func onOpen(_ handler: @escaping EmptyHandler) -> Self {
         handlers.openHander = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onClose(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.closeHander = handler
         return self
     }
     
     @discardableResult
     public func onClose(_ handler: @escaping EmptyHandler) -> Self {
         handlers.closeHander = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onPing(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.pingHander = handler
         return self
     }
     
     @discardableResult
     public func onPing(_ handler: @escaping EmptyHandler) -> Self {
         handlers.pingHander = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onPong(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.pongHander = handler
         return self
     }
     
     @discardableResult
     public func onPong(_ handler: @escaping EmptyHandler) -> Self {
         handlers.pongHander = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onText(_ handler: @escaping TextHandler) -> Self {
         handlers.textHander = handler
        return self
    }
    
    @discardableResult
    public func onText(_ handler: @escaping EmptyHandler) -> Self {
        handlers.textHander = { _,_ in handler() }
        return self
    }
     
     @discardableResult
     public func onByteBuffer(_ handler: @escaping ByteBufferHandler) -> Self {
         handlers.byteBufferHander = handler
        return self
    }
    
    @discardableResult
    public func onByteBuffer(_ handler: @escaping EmptyHandler) -> Self {
        handlers.byteBufferHander = { _,_ in handler() }
        return self
    }
     
     @discardableResult
     public func onBinary(_ handler: @escaping BinaryHandler) -> Self {
         handlers.binaryHander = handler
        return self
    }
    
    @discardableResult
    public func onBinary(_ handler: @escaping EmptyHandler) -> Self {
        handlers.binaryHander = { _,_ in handler() }
        return self
    }
}
