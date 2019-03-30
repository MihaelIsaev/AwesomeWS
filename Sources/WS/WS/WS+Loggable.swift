import Vapor

extension WS: WSLoggable {
    public func log(_ message: WSLogger.Message..., on container: Container) {
        logger.log(message, on: container)
    }
}
