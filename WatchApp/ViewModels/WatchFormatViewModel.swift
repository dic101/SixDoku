import Foundation
import SharedCore
import SharedServices

@MainActor
public final class WatchFormatViewModel: ObservableObject {
    @Published public var selectedFormat: FormatType
    private let settings: SettingsService
    public init(settings: SettingsService = SettingsService()) {
        self.settings = settings
        self.selectedFormat = settings.formatPreference
    }
    public func save() { settings.formatPreference = selectedFormat }
}
