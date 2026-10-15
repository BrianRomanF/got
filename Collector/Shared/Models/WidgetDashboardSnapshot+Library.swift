import Foundation

extension WidgetDashboardSnapshot {
    static func make(from categories: [CollectionCategory]) -> WidgetDashboardSnapshot {
        WidgetDashboardSnapshot(
            books: booksSnapshot(from: categories),
            comics: comicsSnapshot(from: categories),
            games: gamesSnapshot(from: categories),
            vinyl: vinylSnapshot(from: categories),
            updatedAt: .now
        )
    }

    private static func booksSnapshot(from categories: [CollectionCategory]) -> WidgetMetricSnapshot {
        let items = categories
            .filter { $0.template == .books }
            .flatMap(\.allItems)
        let snapshot = BookWidgetSnapshot(items: items)

        return WidgetMetricSnapshot(
            title: L10n.Template.books,
            primaryValue: snapshot.readingCount,
            secondaryValue: snapshot.wishlistCount,
            primaryLabel: L10n.BookWidgets.reading,
            secondaryLabel: L10n.BookWidgets.wishlist,
            highlightTitle: snapshot.currentBook?.title ?? L10n.BookWidgets.currentBookEmpty,
            highlightSubtitle: snapshot.currentBook.map { String(format: L10n.BookProgress.percentComplete, $0.bookProgressPercent) }
                ?? snapshot.nextBook.map { "\(L10n.BookWidgets.nextBook): \($0.title)" }
                ?? L10n.BookWidgets.nextBookEmpty,
            progress: snapshot.currentBook?.bookProgressRatio ?? snapshot.completionRatio
        )
    }

    private static func comicsSnapshot(from categories: [CollectionCategory]) -> WidgetMetricSnapshot {
        let comicCategories = categories.filter { $0.template == .comics }
        let snapshot = comicCategories.reduce(ComicWidgetAccumulator()) { partial, category in
            partial.adding(ComicWidgetSnapshot(category: category))
        }

        return WidgetMetricSnapshot(
            title: L10n.Template.comicsCategory,
            primaryValue: snapshot.ownedIssues,
            secondaryValue: snapshot.missingIssues,
            primaryLabel: L10n.ComicWidgets.owned,
            secondaryLabel: L10n.ComicWidgets.missing,
            highlightTitle: snapshot.currentIssueTitle ?? L10n.ComicWidgets.currentIssueEmpty,
            highlightSubtitle: snapshot.missingIssueText ?? snapshot.incompleteSeriesTitle ?? L10n.ComicWidgets.incompleteSeriesEmpty,
            progress: snapshot.ownershipRatio
        )
    }

    private static func gamesSnapshot(from categories: [CollectionCategory]) -> WidgetMetricSnapshot {
        let items = categories
            .filter { $0.template == .games }
            .flatMap(\.allItems)
        let snapshot = GameWidgetSnapshot(category: CollectionCategory(title: "", subtitle: "", symbolName: "", template: .games, groups: [], items: items))

        return WidgetMetricSnapshot(
            title: L10n.Template.games,
            primaryValue: snapshot.backlogCount,
            secondaryValue: snapshot.completedCount,
            primaryLabel: L10n.GameWidgets.backlog,
            secondaryLabel: L10n.GameWidgets.completed,
            highlightTitle: snapshot.currentGame?.title ?? L10n.GameWidgets.currentGameEmpty,
            highlightSubtitle: snapshot.shortBacklogGame.map { "\(L10n.GameWidgets.shortBacklog): \($0.title)" } ?? L10n.GameWidgets.shortBacklogEmpty,
            progress: snapshot.completionRatio
        )
    }

    private static func vinylSnapshot(from categories: [CollectionCategory]) -> WidgetMetricSnapshot {
        let items = categories
            .filter { $0.template == .vinyl }
            .flatMap(\.allItems)
        let snapshot = VinylWidgetSnapshot(category: CollectionCategory(title: "", subtitle: "", symbolName: "", template: .vinyl, groups: [], items: items))

        return WidgetMetricSnapshot(
            title: L10n.Template.vinylAlbums,
            primaryValue: snapshot.ownedReleases,
            secondaryValue: snapshot.wishlistCount,
            primaryLabel: L10n.VinylWidgets.owned,
            secondaryLabel: L10n.VinylWidgets.wishlist,
            highlightTitle: snapshot.featuredRelease?.title ?? L10n.VinylWidgets.listenTodayEmpty,
            highlightSubtitle: snapshot.wishlistPreview.map { "\(L10n.VinylWidgets.wishlistPick): \($0.title)" } ?? L10n.VinylWidgets.wishlistPickEmpty,
            progress: snapshot.catalogRatio
        )
    }
}

private struct ComicWidgetAccumulator {
    var ownedIssues = 0
    var missingIssues = 0
    var totalIssues = 0
    var currentIssueTitle: String?
    var incompleteSeriesTitle: String?
    var missingIssueText: String?

    var ownershipRatio: Double {
        guard totalIssues > 0 else { return 0 }
        return Double(ownedIssues) / Double(totalIssues)
    }

    func adding(_ snapshot: ComicWidgetSnapshot) -> ComicWidgetAccumulator {
        var updated = self
        updated.ownedIssues += snapshot.ownedIssues
        updated.missingIssues += snapshot.missingIssues
        updated.totalIssues += snapshot.totalIssues
        updated.currentIssueTitle = updated.currentIssueTitle ?? snapshot.currentIssue?.title
        updated.incompleteSeriesTitle = updated.incompleteSeriesTitle ?? snapshot.mostIncompleteSeries?.title
        if snapshot.missingIssueSummary.missingCount > 0 {
            updated.missingIssueText = updated.missingIssueText ?? snapshot.missingIssueSummary.displayText
        }
        return updated
    }
}
