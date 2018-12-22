//
//  Event.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

public struct NoPayload: Codable {}

public struct Event<P: Codable>: Codable {
    public let event: String
    public let payload: P?
    public init (event: String, payload: P? = nil) {
        self.event = event
        self.payload = payload
    }
}

public protocol EventProtocol: Codable {
    associatedtype P: Codable
    
    var event: EventIdentifier<P> { get }
    var payload: P? { get }
}

public struct EventPrototype: Codable {
    public var event: String
}

public struct OutgoingEvent<P: Codable>: Codable {
    var event: String
    var payload: P?
    init(_ event: String, payload: P?) {
        self.event = event
        self.payload = payload
    }
}
