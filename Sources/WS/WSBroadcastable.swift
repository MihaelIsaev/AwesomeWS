//
//  WSBroadcastable.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation
import Vapor

public protocol WSBroadcastable {
    @discardableResult
    func broadcast(on: Worker, _ clients: Set<WSClient>, _ text: String) throws -> Future<Void>
    @discardableResult
    func broadcast(on: Worker, _ clients: Set<WSClient>, _ binary: Data) throws -> Future<Void>
    
    //MARK: Text
    @discardableResult
    func broadcast(on: Worker, _ text: String) throws -> Future<Void>
    @discardableResult
    func broadcast(on: Worker, to channel: String, _ text: String) throws -> Future<Void>
    
    //MARK: Binary
    @discardableResult
    func broadcast(on: Worker, _ binary: Data) throws -> Future<Void>
    @discardableResult
    func broadcast(on: Worker, to channel: String, _ binary: Data) throws -> Future<Void>
    
    //MARK: Codable
    @discardableResult
    func broadcast<T: Codable>(on: Worker, _ event: EventIdentifier<T>, payload: T?) throws -> Future<Void>
    @discardableResult
    func broadcast<T: Codable>(on: Worker, to channel: String, _ event: EventIdentifier<T>, payload: T?) throws -> Future<Void>
}
