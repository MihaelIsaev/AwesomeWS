//
//  Event.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

public struct NoPayload: Codable {}

public struct WSEvent<P: Codable>: Codable {
    public let event: String
    public let payload: P?
    public init (event: String, payload: P? = nil) {
        self.event = event
        self.payload = payload
    }
}

public protocol WSEventProtocol: Codable {
    associatedtype P: Codable
    
    var event: WSEventIdentifier<P> { get }
    var payload: P? { get }
}

public struct WSEventPrototype: Codable {
    public var event: String
}

public struct WSOutgoingEvent<P: Codable>: Codable {
    var event: String
    var payload: P?
    init(_ event: String, payload: P?) {
        self.event = event
        self.payload = payload
    }
}
