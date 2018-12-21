import Foundation

public protocol WSListenable: class {
    func onText(_ client: WSClient, _ text: String)
    func onBinary(_ client: WSClient, _ data: Data)
    func onClose(_ client: WSClient)
    func onError(_ client: WSClient, _ error: Error)
}
