import SwiftUI

struct ProPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var proAccess: ProAccessController
    let message: String

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.Pro.title.uppercased().vintageSafe)
                                .font(ComicTheme.displayFont)
                                .foregroundStyle(ComicTheme.ink)

                            Text(message)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(ComicTheme.ink.opacity(0.76))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .comicPanel(fill: ComicTheme.yellow)

                        VStack(alignment: .leading, spacing: 12) {
                            ProFeatureRow(systemName: "square.grid.2x2.fill", title: L10n.Pro.unlimitedCollections)
                            ProFeatureRow(systemName: "shippingbox.fill", title: L10n.Pro.unlimitedPieces)
                            ProFeatureRow(systemName: "tablecells.fill", title: L10n.Pro.csvImport)
                            ProFeatureRow(systemName: "checklist", title: L10n.Pro.bulkActions)
                            ProFeatureRow(systemName: "tag.fill", title: L10n.Pro.advancedSearch)
                        }
                        .padding(16)
                        .comicPanel(fill: ComicTheme.panel)

                        Text(L10n.Pro.oneTime)
                            .font(.caption.weight(.black))
                            .foregroundStyle(ComicTheme.ink.opacity(0.66))
                            .frame(maxWidth: .infinity, alignment: .center)

                        if proAccess.isProUnlocked {
                            ProStatusBanner(
                                systemName: "checkmark.seal.fill",
                                message: L10n.Pro.unlocked,
                                isError: false
                            )
                        } else if let statusMessage = proAccess.statusMessage {
                            ProStatusBanner(
                                systemName: "info.circle.fill",
                                message: statusMessage,
                                isError: false
                            )
                        }

                        Button {
                            Task {
                                await proAccess.purchasePro()
                            }
                        } label: {
                            HStack {
                                Spacer(minLength: 0)
                                Text(unlockTitle)
                                Spacer(minLength: 0)
                                if proAccess.isLoading {
                                    ProgressView()
                                        .tint(ComicTheme.ink)
                                } else {
                                    Image(systemName: "lock.open.fill")
                                }
                            }
                            .font(.headline.weight(.black))
                            .foregroundStyle(ComicTheme.ink)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 18)
                            .background(ComicTheme.yellow)
                            .overlay(
                                Capsule()
                                    .stroke(ComicTheme.ink, lineWidth: 3)
                            )
                            .clipShape(Capsule())
                            .shadow(color: ComicTheme.ink, radius: 0, x: 4, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(proAccess.isLoading)

                        Button(L10n.Pro.restore) {
                            Task {
                                await proAccess.restorePurchases()
                            }
                        }
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.76))
                        .frame(maxWidth: .infinity)
                        .disabled(proAccess.isLoading)

                        Button(L10n.Pro.redeemCode) {
                            Task {
                                await proAccess.redeemOfferCode()
                            }
                        }
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.76))
                        .frame(maxWidth: .infinity)
                        .disabled(proAccess.isLoading)

                        if let errorMessage = proAccess.errorMessage {
                            ProStatusBanner(
                                systemName: "exclamationmark.triangle.fill",
                                message: errorMessage,
                                isError: true
                            )
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Pro.limitTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(proAccess.isProUnlocked ? L10n.Common.save : L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .task {
                await proAccess.refresh()
            }
        }
    }

    private var unlockTitle: String {
        if let product = proAccess.product {
            "\(L10n.Pro.unlock) - \(product.displayPrice)"
        } else {
            L10n.Pro.unlock
        }
    }
}

private struct ProStatusBanner: View {
    let systemName: String
    let message: String
    let isError: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))

            Text(message)
                .font(.caption.weight(.black))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .foregroundStyle(isError ? ComicTheme.red : ComicTheme.ink)
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(isError ? ComicTheme.red : ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct ProFeatureRow: View {
    let systemName: String
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.red)
                .frame(width: 28)

            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}
