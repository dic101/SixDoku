import SwiftUI

/// iOS banner "Sync delayed" per `ErrorHandlingSpec.md.md:10` — watchOS silent fallback.
public struct SyncStatusBanner: View {
    var message: String?
    public init(message: String?) { self.message = message }
    public var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .clipShape(Capsule())
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityLabel(message)
        }
    }
}
