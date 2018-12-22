//
//  WS+Broadcast.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation
import Vapor

extension WS {
    public func broadcast(on: Worker, _ clients: Set<WSClient>, _ text: String) throws -> Future<Void> {
        return clients.map { $0.emit(text) }.flatten(on: on)
    }
    
    public func broadcast(on: Worker, _ clients: Set<WSClient>, _ binary: Data) throws -> Future<Void> {
        return clients.map { $0.emit(binary) }.flatten(on: on)
    }
    
    func broadcast<T: Codable>(on: Worker, _ clients: Set<WSClient>, _ event: OutgoingEvent<T>) throws -> Future<Void> {
        let jsonData = try JSONEncoder().encode(event)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WSError(reason: "Unable to preapare JSON string for broadcast message")
        }
        return clients.map { $0.emit(jsonString) }.flatten(on: on)
    }
    
    //MARK: Text
    
    public func broadcast(on: Worker, _ text: String) throws -> Future<Void> {
        return try broadcast(on: on, clients, text)
    }
    
    public func broadcast(on: Worker, to channel: String, _ text: String) throws -> Future<Void> {
        return try broadcast(on: on, clients.filter { $0.channels.contains(channel) }, text)
    }
    
    //MARK: Binary
    
    public func broadcast(on: Worker, _ binary: Data) throws -> Future<Void> {
        return try broadcast(on: on, clients, binary)
    }
    
    public func broadcast(on: Worker, to channel: String, _ binary: Data) throws -> Future<Void> {
        return try broadcast(on: on, clients.filter { $0.channels.contains(channel) }, binary)
    }
    
    //MARK: JSON
    
    public func broadcast<T: Codable>(on: Worker, _ event: EventIdentifier<T>, payload: T? = nil) throws -> Future<Void> {
        return try broadcast(on: on, clients, OutgoingEvent(event.uid, payload: payload))
    }
    
    public func broadcast<T: Codable>(on: Worker, to channel: String, _ event: EventIdentifier<T>, payload: T? = nil) throws -> Future<Void> {
        return try broadcast(on: on, clients.filter { $0.channels.contains(channel) }, OutgoingEvent(event.uid, payload: payload))
    }
}
