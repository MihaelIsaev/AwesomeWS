import Vapor

extension HTTPServer.Configuration {
    var address: String {
        let scheme = tlsConfiguration == nil ? "http" : "https"
        return "\(scheme)://\(hostname):\(port)"
    }
}
