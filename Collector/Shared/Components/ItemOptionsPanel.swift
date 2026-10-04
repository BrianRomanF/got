import SwiftUI

struct ItemOptionsPanel: View {
    @Binding var isExpanded: Bool
    @Binding var ownershipFilter: ItemOwnershipFilter
    @Binding var quickFilter: ItemQuickFilter
    @Binding var sortOption: ItemSortOption
    @Binding var displayMode: ItemDisplayMode
    let includesBookFilters: Bool

    private var quickFilters: [ItemQuickFilter] {
        includesBookFilters ? ItemQuickFilter.allCases : [.all, .notes, .noCover]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline.weight(.black))

                    Text(L10n.Options.title.uppercased().vintageSafe)
                        .font(.headline.weight(.black))

                    Spacer(minLength: 0)

                    Text(summary.uppercased().vintageSafe)
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.65))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.black))
                }
                .foregroundStyle(ComicTheme.ink)
                .padding(14)
                .background(ComicTheme.yellow)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 3)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    optionBlock(title: L10n.OwnershipFilter.title) {
                        ComicSegmentedControl(
                            options: ItemOwnershipFilter.allCases,
                            selection: $ownershipFilter,
                            title: { $0.title }
                        )
                    }

                    optionBlock(title: L10n.Filters.quick) {
                        ComicSegmentedControl(
                            options: quickFilters,
                            selection: $quickFilter,
                            title: { $0.title }
                        )
                    }

                    optionBlock(title: L10n.Sort.title) {
                        SettingsLikeMenu(
                            title: sortOption.title,
                            options: ItemSortOption.allCases,
                            selection: $sortOption,
                            optionTitle: { $0.title }
                        )
                    }

                    optionBlock(title: L10n.Settings.defaultDisplay) {
                        ComicSegmentedControl(
                            options: ItemDisplayMode.allCases,
                            selection: $displayMode,
                            title: { $0.title }
                        )
                    }
                }
                .padding(14)
                .comicPanel(fill: .white)
            }
        }
    }

    private var summary: String {
        "\(ownershipFilter.title) - \(sortOption.title)"
    }

    private func optionBlock<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased().vintageSafe)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.72))

            content()
        }
    }
}

private struct SettingsLikeMenu<Option: Identifiable & Hashable>: View {
    let title: String
    let options: [Option]
    @Binding var selection: Option
    let optionTitle: (Option) -> String

    var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selection = option
                } label: {
                    Label(optionTitle(option), systemImage: option == selection ? "checkmark" : "")
                }
            }
        } label: {
            HStack {
                Text(title.uppercased().vintageSafe)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)

                Spacer(minLength: 0)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink.opacity(0.65))
            }
            .padding(12)
            .background(ComicTheme.yellow)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}
