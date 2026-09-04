import Foundation
#if os(watchOS)
import WatchKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Haptic feedback per UIInteractionRules.
public enum HapticsService {
    public static func lightTap() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #elseif canImport(UIKit)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    public static func success() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #elseif canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    public static func error() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.failure)
        #elseif canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        #endif
    }
}
