import Foundation

public typealias OnTextHandler = (WSClient, String) -> Void
public typealias OnBinaryHandler = (WSClient, Data) -> Void
public typealias OnCloseHandler = (WSClient) -> Void
public typealias OnErrorHandler = (WSClient, Error) -> Void

//public class WSDefaultListener: WSListenable {
//    public var onText: OnTextHandler
//    public var onBinary: OnBinaryHandler
//    public var onClose: OnCloseHandler
//    public var onError: OnErrorHandler
//    
//    public func onText(_ client: WSClient, _ text: String) {
//        onText(client, text)
//    }
//    
//    public func onBinary(_ client: WSClient, _ data: Data) {
//        onBinary(client, data)
//    }
//    
//    public func onClose(_ client: WSClient) {
//        onClose(client)
//    }
//    
//    public func onError(_ client: WSClient, _ error: Error) {
//        onError(client, error)
//    }
//}
