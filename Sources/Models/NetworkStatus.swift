public struct NetworkStatus: Equatable, Sendable {
	public let connected: Bool?
	public let expensive: Bool?
	public let wasChanged: Bool?
    public let vpnEnabled: Bool?

	public init(
        connected: Bool? = nil,
        expensive: Bool? = nil,
        wasChanged: Bool? = nil,
        vpnEnabled: Bool? = nil
	) {
		self.connected = connected
		self.expensive = expensive
		self.wasChanged = wasChanged
        self.vpnEnabled = vpnEnabled
	}
}
