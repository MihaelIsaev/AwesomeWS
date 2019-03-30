import Foundation

open class WSBindController: WSObserver {
    typealias BindHandler = (WSClient, Data) -> Void
    
    var binds: [String: BindHandler] = [:]
    
    public func bind<P: Codable>(_ identifier: WSEventIdentifier<P>, _ handler: @escaping (WSClient, P?) -> Void) {
        binds[identifier.uid] = { [weak self] client, data in
            do {
                let res = try JSONDecoder().decode(WSEvent<P>.self, from: data)
                handler(client, res.payload)
            } catch {
                self?.logger?.log(.error(String(describing: error)), on: client.req)
            }
        }
    }
    
    public func bind<P: Codable>(_ identifier: WSEventIdentifier<P>, _ handler: @escaping (WSClient, P) -> Void) {
        binds[identifier.uid] = { [weak self] client, data in
            do {
                let res = try JSONDecoder().decode(WSEvent<P>.self, from: data)
                guard let payload = res.payload else { throw WSError(reason: "Unable to unwrap payload") }
                handler(client, payload)
            } catch {
                self?.logger?.log(.error(String(describing: error)), on: client.req)
            }
        }
    }
    
    /// Calls when a new client connects. Override this function to handle `onOpen`.
    open func onOpen(_ client: WSClient) {}
    
    /// Calls when a client disconnects. Override this function to handle `onClose`.
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
            let prototype = try JSONDecoder().decode(WSEventPrototype.self, from: data)
            switch prototype.event {
            case "join": ws.joining(client, data: data, on: client.req)
            case "leave": ws.leaving(client, data: data, on: client.req)
            default: break
            }
            if let bind = binds.first(where: { $0.0 == prototype.event }) {
                bind.value(client, data)
            }
        } catch {
            logger?.log(.error(String(describing: error)), on: client.req)
        }
    }
}
