import Vapor
import NIOWebSocket

public protocol Subscribable {
    @discardableResult
    func subscribe(to channels: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void>
    @discardableResult
    func subscribe(to channels: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void>
    @discardableResult
    func unsubscribe(from channels: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void>
    @discardableResult
    func unsubscribe(from channels: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void>
}

extension Subscribable {
    public func subscribe(to channels: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        subscribe(to: channels, on: eventLoop)
    }
    
    public func unsubscribe(from channels: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        unsubscribe(from: channels, on: eventLoop)
    }
}

internal protocol _Subscribable: AnyObject, Subscribable {
    var eventLoop: EventLoop { get }
    var clients: [_AnyClient] { get }
}

extension _Subscribable {
    public func subscribe(to channels: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        subscribe(to: channels, on: eventLoop)
    }
    
    public func subscribe(to channels: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        self.eventLoop.submit {
            channels.forEach { channel in
                self.clients.forEach {
                    $0.channels.insert(channel)
                }
            }
        }.hop(to: eventLoop)
    }
    
    public func unsubscribe(from channels: String..., on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        unsubscribe(from: channels, on: eventLoop)
    }
    
    public func unsubscribe(from channels: [String], on eventLoop: EventLoop) -> EventLoopFuture<Void> {
        self.eventLoop.submit {
            channels.forEach { channel in
                self.clients.forEach {
                    $0.channels.remove(channel)
                }
            }
        }.hop(to: eventLoop)
    }
}

// MARK: - EventLoopFuture

extension EventLoopFuture where Value: Subscribable {
    public func subscribe(to channels: String...) -> EventLoopFuture<Void> {
        subscribe(to: channels)
    }
    
    public func subscribe(to channels: [String]) -> EventLoopFuture<Void> {
        flatMap { $0.subscribe(to: channels, on: self.eventLoop) }
    }
    
    public func unsubscribe(from channels: String...) -> EventLoopFuture<Void> {
        unsubscribe(from: channels)
    }
    
    public func unsubscribe(from channels: [String]) -> EventLoopFuture<Void> {
        flatMap { $0.unsubscribe(from: channels, on: self.eventLoop) }
    }
}
