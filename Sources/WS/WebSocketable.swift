//
//  WebSocketable.swift
//  WS
//
//  Created by Mihael Isaev on 21/12/2018.
//

import Foundation
import Vapor

protocol WebSocketable {
    /// See `onText(...)`.
    var onTextCallback: (WebSocket, String) -> () { get set }
    
    /// See `onBinary(...)`.
    var onBinaryCallback: (WebSocket, Data) -> () { get set }
    
    /// See `onError(...)`.
    var onErrorCallback: (WebSocket, Error) -> () { get set }
    
    /// A `Future` that will be completed when the `WebSocket` closes.
    var onClose: Future<Void> { get set }
}
