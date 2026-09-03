import Foundation
import SharedCore
import SharedServices

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var formatPreference: FormatType {
        didSet { settings.formatPreference = formatPreference }
    }

    private let settings: SettingsService

    public init(settings: SettingsService = SettingsService()) {
        self.settings = settings
        self.formatPreference = settings.formatPreference
    }
}
