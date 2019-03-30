import Foundation
import Vapor

extension WS {
    func decodeEvent<P: Codable>(by identifier: WSEventIdentifier<P>, with data: Data) throws -> WSEvent<P> {
        return try JSONDecoder().decode(WSEvent<P>.self, from: data)
    }
    
    func joining(_ client: WSClient, data: Data, on container: Container) {
        if let event = try? decodeEvent(by: .join, with: data), let payload = event.payload {
            let cid = payload.channel.uuidString
            let channel = channels.first { $0.cid == cid } ?? channels.insert(WSChannel(cid)).memberAfterInsert
            channel.clients.insert(client)
            client.channels.insert(cid)
            channels.insert(channel)
            
            logger.log(.info("➡️ Some client has joined some channel"),
                           .debug("➡️ Client \(client.cid) has joined channel \(cid)"), on: container)
        }
    }
    
    func leaving(_ client: WSClient, data: Data, on container: Container) {
        if let event = try? decodeEvent(by: .leave, with: data), let payload = event.payload {
            let cid = payload.channel.uuidString
            client.channels.remove(cid)
            channels.first { $0.cid == cid }?.clients.remove(client)
            logger.log(.info("⬅️ Some client has left some channel"),
                           .debug("⬅️ Client \(client.cid) has left channel \(cid)"), on: container)
        }
    }
}
