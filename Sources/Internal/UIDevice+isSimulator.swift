import UIKit

extension UIDevice {
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
                 true
         #else
                 false
         #endif
    }
}
