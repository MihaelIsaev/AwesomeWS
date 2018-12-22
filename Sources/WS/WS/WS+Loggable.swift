extension WS: WSLoggable {
    public func log(_ message: WSLogger.Message...) {
        logger.log(message)
    }
}
