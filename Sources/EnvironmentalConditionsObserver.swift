import UIKit
import Combine

@available(iOS 14, *)
@MainActor
public class EnvironmentalConditionsObserver: ObservableObject {
    private let deviceBatteryLevelObserver: DeviceBatteryLevelObserver
    private let devicePowerModeObserver: DevicePowerModeObserver
	private let deviceNetworkStateObserver: DeviceNetworkStateObserver
    
    @Published public private(set) var deviceBatteryState: UIDevice.BatteryState
    @Published public private(set) var deviceBatteryLevel: Float
    @Published public private(set) var devicePowerModeState: UIDevice.PowerModeState
	@Published public private(set) var deviceNetworkStatus: NetworkStatus

    public init() {
        self.deviceBatteryLevelObserver = .init()
        self.devicePowerModeObserver = .init()
		self.deviceNetworkStateObserver = .init()

        deviceBatteryLevel = deviceBatteryLevelObserver.deviceBatteryLevel
        deviceBatteryState = deviceBatteryLevelObserver.deviceBatteryState
        devicePowerModeState = devicePowerModeObserver.devicePowerModeState
		deviceNetworkStatus = deviceNetworkStateObserver.deviceNetworkStatus
		
        initPipelines()
    }
    
    private func initPipelines() {
        initDeviceBatteryStateObserver()
        initDeviceBatteryLevelObserver()
        initDevicePowerModeObserver()
		initDeviceNetworkStateObserver()
    }
    
    private func initDeviceBatteryStateObserver() {
        deviceBatteryLevelObserver.$deviceBatteryState
            .receive(on: DispatchQueue.main)
            .assign(to: &$deviceBatteryState)
    }
    
    private func initDeviceBatteryLevelObserver() {
        deviceBatteryLevelObserver.$deviceBatteryLevel
            .receive(on: DispatchQueue.main)
            .assign(to: &$deviceBatteryLevel)
    }
    
    private func initDevicePowerModeObserver() {
        devicePowerModeObserver.$devicePowerModeState
            .receive(on: DispatchQueue.main)
            .assign(to: &$devicePowerModeState)
    }
	
	private func initDeviceNetworkStateObserver() {
		deviceNetworkStateObserver.$deviceNetworkStatus
			.removeDuplicates()
			.receive(on: DispatchQueue.main)
			.assign(to: &$deviceNetworkStatus)
	}
}
