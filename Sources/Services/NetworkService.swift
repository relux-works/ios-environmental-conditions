import Foundation
@preconcurrency import Combine
import Network

actor NetworkService {
	private let monitor = NWPathMonitor()
	
	private let queue = DispatchQueue(label: "NetworkMonitor", qos: .userInitiated)
	private(set) var status: NetworkStatus = .init()
	private nonisolated let networkSub = CurrentValueSubject<NetworkStatus, Never>(.init())

	public nonisolated var networkPub: AnyPublisher<NetworkStatus, Never> {
		networkSub
			.removeDuplicates()
			.eraseToAnyPublisher()
	}
	
	public init() {
		startWatchNetworkCondition()
	}
	
	public func start() {
		startWatchNetworkCondition()
	}
	
	private nonisolated func startWatchNetworkCondition() {
		let t1 = Date()
		monitor.pathUpdateHandler = { [weak self] path in
            Task {
                guard let strongSelf = self else {
                    return
                }

                let prevStatus = await strongSelf.status
                let nextStatus = await strongSelf.buildStatus(path: path, prevStatus: prevStatus)
                if prevStatus != nextStatus {
                    if #available(iOS 14, *) {
                        log("network status: \(path.status), isExpensive: \(path.isExpensive)", category: .default)
                    }
                }

                await strongSelf.setStatus(nextStatus)
            }
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

    private func setStatus(_ status: NetworkStatus) {
        self.status = status
        networkSub.send(status)
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

        return allKeys
            .contains { key in
                Self.vpnProtocols.contains { ptcl in key.contains(ptcl)}
            }
    }
}
