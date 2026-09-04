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
            Section("Developer") {
                Button(viewModel.isSeeding ? "Seeding…" : "Seed Catalog to iCloud") {
                    viewModel.seedCatalog()
                }
                .disabled(viewModel.isSeeding)
                if let status = viewModel.seedStatus {
                    Text(status).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
