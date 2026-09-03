import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    public init() {}
    public var body: some View {
        Form {
            Section("Game") {
                FormatSelectorView(selection: $viewModel.formatPreference)
            }
            Section("About") {
                Text("SixDoku MVP — themes & daily puzzles coming soon")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
