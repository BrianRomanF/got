import SwiftUI

struct HomeUtilityDashboardView: View {
    let snapshot: WidgetDashboardSnapshot
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.grid.2x2.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(ComicTheme.red)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.Dashboard.utilityTitle.uppercased().vintageSafe)
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.red)

                        Text(L10n.Dashboard.utilitySubtitle)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(ComicTheme.ink.opacity(0.72))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title3.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 10) {
                    ForEach(snapshot.metrics) { metric in
                        HomeUtilityMetricRow(metric: metric)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .comicPanel(fill: ComicTheme.panel)
    }
}

private struct HomeUtilityMetricRow: View {
    let metric: WidgetMetricSnapshot

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(metric.title.uppercased().vintageSafe)
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text("\(Int(metric.progress * 100))%")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.72))
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(ComicTheme.paper)
                        Capsule()
                            .fill(ComicTheme.green)
                            .frame(width: metric.progress > 0 ? max(8, proxy.size.width * metric.progress) : 0)
                    }
                }
                .frame(height: 8)
                .overlay(
                    Capsule()
                        .stroke(ComicTheme.ink, lineWidth: 1)
                )

                Text(metric.highlightTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.72))
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                metricPill(value: metric.primaryValue, label: metric.primaryLabel)
                metricPill(value: metric.secondaryValue, label: metric.secondaryLabel)
            }
        }
        .padding(10)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private func metricPill(value: Int, label: String) -> some View {
        VStack(spacing: 1) {
            Text("\(value)")
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)

            Text(label.uppercased().vintageSafe)
                .font(.caption2.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(width: 58)
    }
}

extension WidgetMetricSnapshot: Identifiable {
    var id: String {
        title
    }
}
