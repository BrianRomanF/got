import SwiftUI

struct GroupToolbarButton: View {
    let systemName: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
        }
        .accessibilityLabel(label)
    }
}
