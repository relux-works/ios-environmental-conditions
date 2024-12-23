import Foundation
import Combine
import Network

#warning("exposure to data race around access to status; change network service to Actor")
class NetworkService {
	private let monitor = NWPathMonitor()
	
	private let queue = DispatchQueue(label: "NetworkMonitor", qos: .userInitiated)
	private(set) var status: NetworkStatus = .init()
	private let networkSub = CurrentValueSubject<NetworkStatus, Never>(.init())
	
	public var networkPub: AnyPublisher<NetworkStatus, Never> {
		networkSub
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
	
	public init () {
		startWatchNetworkCondition()
	}
	
	public func start() {
		startWatchNetworkCondition()
	}
	
	private func startWatchNetworkCondition() {
		let t1 = Date()
		monitor.pathUpdateHandler = { [weak self] path in
			guard let strongSelf = self else {
				return
			}
			
			let prevStatus = strongSelf.status
			let nextStatus = strongSelf.buildStatus(path: path, prevStatus: prevStatus)
			if prevStatus != nextStatus {
				if #available(iOS 14, *) {
					log("network status: \(path.status), isExpensive: \(path.isExpensive)", category: .default)
				}
			}
			
			strongSelf.status = nextStatus
			strongSelf.networkSub.send(nextStatus)
		}
		
		monitor.start(queue: queue)
		let t2 = t1.distance(to: Date())
		log("starting network monitor took \(t2 * 1000) ms", category: .performance)
	}
	
	private func buildStatus(path: NWPath, prevStatus: NetworkStatus) -> NetworkStatus {
		let isExpensive = path.isExpensive
		let isConnected = path.status == .satisfied
		let wasChanged = prevStatus.connected != isConnected
        let isVpnEnabled = checkVPNEnabled()

		return .init(
			connected: isConnected,
			expensive: isExpensive,
			wasChanged: wasChanged,
            vpnEnabled: isVpnEnabled
		)
	}
}

// vpn helper
extension NetworkService {
    private static let vpnProtocols = ["tap", "tun", "ppp", "ipsec", "utun"]

    private func checkVPNEnabled() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }

        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
              let allKeys = keys.allKeys as? [String]
              else { return false }

        return zip(allKeys, Self.vpnProtocols)
            .contains(where: { $0.contains($1) })
    }
}
