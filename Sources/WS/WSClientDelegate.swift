import Foundation

protocol WSClientDelegate: class {
    func onTextHandler(_ client: WSClient, text: String)
    func onBinaryHandler(_ client: WSClient, data: Data)
    func onErrorHandler(_ client: WSClient, error: Error)
    func onCloseHandler()
}
