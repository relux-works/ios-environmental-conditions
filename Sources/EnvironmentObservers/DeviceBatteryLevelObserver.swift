import Combine
import UIKit

@available(iOS 14, *)
@MainActor
class DeviceBatteryLevelObserver: ObservableObject {
    
    @Published internal private(set) var deviceBatteryState: UIDevice.BatteryState
    @Published internal private(set) var deviceBatteryLevel: Float

    init() {
        Self.enableBatteryMonitoring()
        deviceBatteryLevel =
            UIDevice.current.isSimulator
                ? 1
                : UIDevice.current.batteryLevel

        deviceBatteryState = UIDevice.current.batteryState
        initPipelines()
    }
    
    private static let batteryLevelNotificationName = UIDevice.batteryLevelDidChangeNotification
    private static let batteryStateNotificationName = UIDevice.batteryStateDidChangeNotification
    
	
    private static func enableBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    private func initPipelines() {
        setupBatteryLevelObserver()
        setupBatteryStateObserver()
    }
    
    private func setupBatteryLevelObserver() {
        NotificationCenter.default.publisher(for: Self.batteryLevelNotificationName)
            .subscribe(on: DispatchQueue.main)
            .map { _ in
                UIDevice.current.batteryLevel
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$deviceBatteryLevel)
    }
    
    private func setupBatteryStateObserver() {
        NotificationCenter.default.publisher(for: Self.batteryStateNotificationName)
            .subscribe(on: DispatchQueue.main)
            .map { _ in
                UIDevice.current.batteryState
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$deviceBatteryState)
    }
    
}
