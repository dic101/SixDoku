import SwiftUI
import SharedServices

@main
struct SixDokuWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
                .task {
                    await SyncManager().syncWhenOnline()
                }
        }
    }
}
