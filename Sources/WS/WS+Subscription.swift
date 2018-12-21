import Foundation
import WebSocket
import Vapor

extension WS {
    func subscribe(_ client: WSClient, to room: String) {
        client.channels.insert(room)
    }
    
    func unsubscribe(_ client: WSClient, from room: String) {
        client.channels.remove(room)
    }
}
