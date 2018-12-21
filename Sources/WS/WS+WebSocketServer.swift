import Foundation
import Vapor

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
