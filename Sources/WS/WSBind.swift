//
//  WSBind.swift
//  WS
//
//  Created by Mihael Isaev on 22/12/2018.
//

import Foundation

open class WSBind: WSObserver {
    typealias BindHandler = (WSClient, Data) -> Void
    
    var binds: [String: BindHandler] = [:]
    
    public func bind<P: Codable>(_ identifier: EventIdentifier<P>, _ handler: @escaping (WSClient, P?) -> Void) {
        binds[identifier.uid] = { client, data in
            do {
                let res = try JSONDecoder().decode(Event<P>.self, from: data)
                handler(client, res.payload)
            } catch {
                print(error)
            }
        }
    }
    
    open func onOpen(_ client: WSClient) {}
    open func onClose(_ client: WSClient) {}
    
    public override func wsOnOpen(_ ws: WS, _ client: WSClient) -> Bool {
        let result = super.wsOnOpen(ws, client)
        if result {
            onOpen(client)
        }
        return result
    }
    
    public override func wsOnClose(_ ws: WS, _ client: WSClient) {
        super.wsOnClose(ws, client)
        onClose(client)
    }
    
    public override func wsOnText(_ ws: WS, _ client: WSClient, _ text: String) {
        super.wsOnText(ws, client, text)
        if let data = text.data(using: .utf8) {
            proceedData(ws, client, data: data)
        }
    }
    
    public override func wsOnBinary(_ ws: WS, _ client: WSClient, _ data: Data) {
        super.wsOnBinary(ws, client, data)
        proceedData(ws, client, data: data)
    }
    
    func proceedData(_ ws: WS, _ client: WSClient, data: Data) {
        do {
            let prototype = try JSONDecoder().decode(EventPrototype.self, from: data)
            switch prototype.event {
            case "join": ws.joining(client, data: data)
            case "leave": ws.leaving(client, data: data)
            default: break
            }
            if let bind = binds.first(where: { $0.0 == prototype.event }) {
                bind.value(client, data)
            }
        } catch {
            print(error)
        }
    }
}
