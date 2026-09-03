import SwiftUI
import SharedCore

public struct FormatSelectorView: View {
    @Binding var selection: FormatType
    public init(selection: Binding<FormatType>) { self._selection = selection }
    public var body: some View {
        Picker("Format", selection: $selection) {
            Text("2×3").tag(FormatType.twoByThree)
            Text("3×2").tag(FormatType.threeByTwo)
        }
        .pickerStyle(.segmented)
    }
}
