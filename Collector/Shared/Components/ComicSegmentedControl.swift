import SwiftUI

struct ComicSegmentedControl<Option: Identifiable & Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let title: (Option) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    Text(title(option).uppercased())
                        .font(.caption.weight(.black))
                        .foregroundStyle(selection == option ? ComicTheme.ink : ComicTheme.ink.opacity(0.68))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selection == option ? ComicTheme.yellow : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(ComicTheme.ink, lineWidth: selection == option ? 3 : 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                        .shadow(
                            color: selection == option ? ComicTheme.ink : .clear,
                            radius: 0,
                            x: 3,
                            y: 3
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
