import SwiftUI
import SharedCore

public struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    public init() {}
    public var body: some View {
        List {
            Section("Overview") {
                Text("Completed: \(viewModel.completedCount)")
                Text("Streak: \(viewModel.streakDays) days")
            }
            Section("By Format") {
                ForEach(FormatType.allCases, id: \.self) { f in
                    Text("\(f.rawValue): \(viewModel.formatUsage[f] ?? 0)")
                }
            }
        }
        .navigationTitle("Stats")
        .onAppear { viewModel.load() }
    }
}
