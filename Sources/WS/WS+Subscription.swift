import Foundation
import WebSocket
import Vapor

extension WS {
    func subscribe(_ client: WSClient, to room: String) {
        client.rooms.insert(room)
    }
    
    func unsubscribe(_ client: WSClient, from room: String) {
        client.rooms.remove(room)
    }
}
