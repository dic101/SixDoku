import SwiftUI
import SharedCore

public struct WatchFormatSelectorView: View {
    @StateObject private var viewModel = WatchFormatViewModel()
    public init() {}
    public var body: some View {
        Picker("Format", selection: $viewModel.selectedFormat) {
            Text("2×3").tag(FormatType.twoByThree)
            Text("3×2").tag(FormatType.threeByTwo)
        }
        .onChange(of: viewModel.selectedFormat) { viewModel.save() }
    }
}
