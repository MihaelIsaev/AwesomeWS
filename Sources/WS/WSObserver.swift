import Foundation

open class WSObserver: WSControllerable {
    public weak var logger: WSLoggable?
    
    public init () {}
    
    //MARK: WSDelegate
    
    public func wsOnOpen(_ ws: WS, _ client: WSClient) -> Bool {
        return ws.insertClient(client)
    }
    
    public func wsOnClose(_ ws: WS, _ client: WSClient) {
        ws.removeClient(client)
    }
    
    public func wsOnText(_ ws: WS, _ client: WSClient, _ text: String) {}
    public func wsOnBinary(_ ws: WS, _ client: WSClient, _ data: Data) {}
    public func wsOnError(_ ws: WS, _ client: WSClient, _ error: Error) {}
}
