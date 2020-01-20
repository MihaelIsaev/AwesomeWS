import Vapor
import NIOWebSocket

public protocol Subscribable {
    @discardableResult
    func subscribe(to channels: String...) -> EventLoopFuture<Void>
    @discardableResult
    func subscribe(to channels: [String]) -> EventLoopFuture<Void>
    @discardableResult
    func unsubscribe(from channels: String...) -> EventLoopFuture<Void>
    @discardableResult
    func unsubscribe(from channels: [String]) -> EventLoopFuture<Void>
}

extension Subscribable {
    public func subscribe(to channels: String...) -> EventLoopFuture<Void> {
        subscribe(to: channels)
    }
    
    public func unsubscribe(from channels: String...) -> EventLoopFuture<Void> {
        unsubscribe(from: channels)
    }
}

internal protocol _Subscribable: class, Subscribable {
    var eventLoop: EventLoop { get }
    var clients: [_AnyClient] { get }
}

extension _Subscribable {
    public func subscribe(to channels: String...) -> EventLoopFuture<Void> {
        subscribe(to: channels)
    }
    
    public func subscribe(to channels: [String]) -> EventLoopFuture<Void> {
        channels.forEach { channel in
            self.clients.forEach {
                $0.channels.insert(channel)
            }
        }
        return eventLoop.future()
    }
    
    public func unsubscribe(from channels: String...) -> EventLoopFuture<Void> {
        unsubscribe(from: channels)
    }
    
    public func unsubscribe(from channels: [String]) -> EventLoopFuture<Void> {
        channels.forEach { channel in
            self.clients.forEach {
                $0.channels.remove(channel)
            }
        }
        return eventLoop.future()
    }
}

// MARK: - EventLoopFuture

extension EventLoopFuture: Subscribable where Value: Subscribable {
    public func subscribe(to channels: [String]) -> EventLoopFuture<Void> {
        flatMap { $0.subscribe(to: channels) }
    }
    
    public func unsubscribe(from channels: [String]) -> EventLoopFuture<Void> {
        flatMap { $0.unsubscribe(from: channels) }
    }
}
