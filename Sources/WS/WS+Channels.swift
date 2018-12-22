//
//  WS+Channels.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

extension WS {
    func decodeEvent<P: Codable>(by identifier: WSEventIdentifier<P>, with data: Data) throws -> WSEvent<P> {
        return try JSONDecoder().decode(WSEvent<P>.self, from: data)
    }
    
    func joining(_ client: WSClient, data: Data) {
        if let event = try? decodeEvent(by: .join, with: data) {
            let uid = String(describing: event.payload?.channel)
            let channel = channels.first { $0.uid == uid } ?? channels.insert(WSChannel(uid)).memberAfterInsert
            channel.clients.append(client)
            print("join event to channel: " + uid)
        }
    }
    
    func leaving(_ client: WSClient, data: Data) {
        if let event = try? decodeEvent(by: .leave, with: data) {
            let uid = String(describing: event.payload?.channel)
            channels.first { $0.uid == uid }?.clients.removeAll { $0.cid == client.cid }
            print("leave event channel: " + uid)
        }
    }
}
