import Foundation
import WebSocket
import Vapor

extension WS {
    public func onConnection(_ ws: WebSocket, _ req: Request) throws {
        let client = WSClient(ws, req)
        clients.append(client)
        ws.onText { ws, text in self.onText(client, text) }
        ws.onBinary { ws, data in self.onBinary(client, data) }
        ws.onClose.always { self.onClose(client) }
        ws.onError { ws, error in self.onError(client, error) }
    }
    
    private func onText(_ client: WSClient, _ text: String) {
        
    }
    
    private func onBinary(_ client: WSClient, _ data: Data) {
//        do {
//            let message = try JSONDecoder().decode(DataMessage.self, from: data)
//            switch message.type {
//            case .subscribe:
//                if let data = message.data,
//                    let subscription = try? JSONDecoder().decode(SubscriptionData.self, from: data) {
//                    subscribe(client, subscription)
//                }
//            case .unsubscribe:
//                if let data = message.data,
//                    let subscription = try? JSONDecoder().decode(SubscriptionData.self, from: data) {
//                    unsubscribe(client, subscription)
//                }
//            default: break
//            }
//        } catch {
//            debugPrint("[WS] onData: can't decode: \(error)")
//        }
    }
    
    private func onClose(_ client: WSClient) {
        //if let index = self.clients.index(where: { c -> Bool in
        //    return c === client
        //}) {
        //    self.clients.remove(at: index)
        //}
        //            DispatchQueue.global().async {
        //                sleep(2)
        //                print("[WS] onClose after 2 seconds: isClosed=\(ws.isClosed)")
        //                ws.send("check sending on closed ws")
        //            }
    }
    
    private func onError(_ client: WSClient, _ error: Error) {
        debugPrint("[WS] onError: \(error)")
    }
}
