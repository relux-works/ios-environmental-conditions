public struct NetworkStatus: Equatable {
	public let connected: Bool?
	public let expensive: Bool?
	public let wasChanged: Bool?
	
	public init(
		connected: Bool? = nil, expensive: Bool? = nil, wasChanged: Bool? = nil
	) {
		self.connected = connected
		self.expensive = expensive
		self.wasChanged = wasChanged
	}
}
