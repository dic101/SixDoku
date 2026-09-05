import SwiftUI
import SharedCore
import SharedServices

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var themes = ThemeManager()
    @StateObject private var hints = HintsManager()
    // Grid-theme choice must never drive row text color: explicit
    // light/dark variant instead so names stay readable in both schemes.
    @Environment(\.colorScheme) private var colorScheme
    public init() {}
    public var body: some View {
        Form {
            Section("Game") {
                FormatSelectorView(selection: $viewModel.formatPreference)
                Toggle("Hints", isOn: Binding(
                    get: { hints.isEnabled },
                    set: { hints.setEnabled($0) }
                ))
                .accessibilityHint("Turn hints on or off")
                Text("Turn hints on or off. Syncs via iCloud.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Grid Theme") {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button {
                        themes.setTheme(theme)
                    } label: {
                        HStack(spacing: 12) {
                            // Mini grid preview: given cells vs editable cells.
                            VStack(spacing: 2) {
                                HStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(theme.clueBackground)
                                        .frame(width: 16, height: 16)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(theme.cellBackground)
                                        .frame(width: 16, height: 16)
                                }
                                HStack(spacing: 2) {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(theme.cellBackground)
                                        .frame(width: 16, height: 16)
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(theme.clueBackground)
                                        .frame(width: 16, height: 16)
                                }
                            }
                            .frame(width: 34, height: 34)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 0.5)
                            )
                            VStack(alignment: .leading) {
                                Text(theme.displayName)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                Text(theme.description)
                                    .font(.caption)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                            Spacer()
                            if themes.theme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(theme.accent)
                            }
                        }
                    }
                }
                Text("Syncs to your watch via iCloud")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("About") {
                Text("6Doku MVP — daily puzzles coming soon")
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
