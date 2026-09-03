import SwiftUI
import SharedServices

@main
struct SixDokuApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    await SyncManager().syncWhenOnline()
                }
        }
    }
}
