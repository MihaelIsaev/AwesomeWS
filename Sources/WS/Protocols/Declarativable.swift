import Vapor

public typealias EmptyHandler = () -> Void
public typealias OpenCloseHandler = (AnyClient) -> Void
public typealias TextHandler = (AnyClient, String) -> Void
public typealias ByteBufferHandler = (AnyClient, ByteBuffer) -> Void
public typealias BinaryHandler = (AnyClient, Data) -> Void

public class DeclarativeHandlers {
    var openHandler: OpenCloseHandler?
    var closeHandler: OpenCloseHandler?
    var pingHandler: OpenCloseHandler?
    var pongHandler: OpenCloseHandler?
    var textHandler: TextHandler?
    var byteBufferHandler: ByteBufferHandler?
    var binaryHandler: BinaryHandler?
}

public protocol Declarativable: AnyObserver {
    var handlers: DeclarativeHandlers { get }
}

internal protocol _Declarativable: Declarativable, _AnyObserver {
    var handlers: DeclarativeHandlers { get set }
}

extension _Declarativable {
    func _on(open client: _AnyClient) {
        handlers.openHandler?(client)
    }
    
    func _on(close client: _AnyClient) {
        handlers.closeHandler?(client)
    }
    
    func _on(ping client: _AnyClient) {
        handlers.pingHandler?(client)
    }
    
    func _on(pong client: _AnyClient) {
        handlers.pongHandler?(client)
    }
    
    func _on(text: String, client: _AnyClient) {
        guard let handler = handlers.textHandler else {
            logger.warning("[⚡️] ❗️📥❗️ \(description) received `text` but handler is nil")
            return
        }
        handler(client, text)
    }
    
    func _on(byteBuffer: ByteBuffer, client: _AnyClient) {
        guard let handler = handlers.byteBufferHandler else {
            logger.warning("[⚡️] ❗️📥❗️ \(description) received `byteBuffer` but handler is nil")
            return
        }
        handler(client, byteBuffer)
    }
    
    func _on(data: Data, client: _AnyClient) {
        guard let handler = handlers.binaryHandler else {
            logger.warning("[⚡️] ❗️📥❗️ \(description) received `binary data` but handler is nil")
            return
        }
        handler(client, data)
    }
}

extension Declarativable {
    @discardableResult
     public func onOpen(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.openHandler = handler
         return self
     }
     
     @discardableResult
     public func onOpen(_ handler: @escaping EmptyHandler) -> Self {
         handlers.openHandler = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onClose(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.closeHandler = handler
         return self
     }
     
     @discardableResult
     public func onClose(_ handler: @escaping EmptyHandler) -> Self {
         handlers.closeHandler = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onPing(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.pingHandler = handler
         return self
     }
     
     @discardableResult
     public func onPing(_ handler: @escaping EmptyHandler) -> Self {
         handlers.pingHandler = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onPong(_ handler: @escaping OpenCloseHandler) -> Self {
         handlers.pongHandler = handler
         return self
     }
     
     @discardableResult
     public func onPong(_ handler: @escaping EmptyHandler) -> Self {
         handlers.pongHandler = { _ in handler() }
         return self
     }
     
     @discardableResult
     public func onText(_ handler: @escaping TextHandler) -> Self {
         handlers.textHandler = handler
        return self
    }
    
    @discardableResult
    public func onText(_ handler: @escaping EmptyHandler) -> Self {
        handlers.textHandler = { _,_ in handler() }
        return self
    }
     
     @discardableResult
     public func onByteBuffer(_ handler: @escaping ByteBufferHandler) -> Self {
         handlers.byteBufferHandler = handler
        return self
    }
    
    @discardableResult
    public func onByteBuffer(_ handler: @escaping EmptyHandler) -> Self {
        handlers.byteBufferHandler = { _,_ in handler() }
        return self
    }
     
     @discardableResult
     public func onBinary(_ handler: @escaping BinaryHandler) -> Self {
         handlers.binaryHandler = handler
        return self
    }
    
    @discardableResult
    public func onBinary(_ handler: @escaping EmptyHandler) -> Self {
        handlers.binaryHandler = { _,_ in handler() }
        return self
    }
}
