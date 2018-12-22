//
//  WSPure.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

open class WSPure: WSObserver {
    public typealias OnOpenHandler = (WSClient) -> Void
    public var onOpen: OnOpenHandler?
    
    public typealias OnCloseHandler = () -> Void
    public var onClose: OnCloseHandler?
    
    public typealias OnTextHandler = (WSClient, String) -> Void
    public var onText: OnTextHandler?
    
    public typealias OnBinaryHandler = (WSClient, Data) -> Void
    public var onBinary: OnBinaryHandler?
    
    public typealias OnErrorHandler = (WSClient, Error) -> Void
    public var onError: OnErrorHandler?
    
    override public func wsOnOpen(_ ws: WS, _ client: WSClient) -> Bool {
        if super.wsOnOpen(ws, client) {
            onOpen?(client)
            return true
        }
        return false
    }

    override public func wsOnClose(_ ws: WS, _ client: WSClient) {
        super.wsOnClose(ws, client)
        onClose?()
    }

    override public func wsOnText(_ ws: WS, _ client: WSClient, _ text: String) {
        onText?(client, text)
    }

    override public func wsOnBinary(_ ws: WS, _ client: WSClient, _ data: Data) {
        onBinary?(client, data)
    }

    override public func wsOnError(_ ws: WS, _ client: WSClient, _ error: Error) {
        onError?(client, error)
    }
}
