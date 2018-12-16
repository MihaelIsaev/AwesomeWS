import Vapor
import WebSocket
import Foundation

extension WS {
    public enum Status: String {
        case disconnected, connecting, connected
    }
    
    public enum MessageType: String, Codable {
        case subscribe, unsubscribe, notification
    }
    
//    struct SubscriptionData: Codable {
//        var channel: Chan
//        var data: Data?
//        init(_ channel: Chan, data: Data? = nil) {
//            self.channel = channel
//            self.data = data
//        }
//    }
//    
//    struct DataMessage: Codable {
//        var type: MessageType
//        var data: Data?
//        init (_ type: MessageType, data: Data? = nil) {
//            self.type = type
//            self.data = data
//        }
//    }
    
    
}
