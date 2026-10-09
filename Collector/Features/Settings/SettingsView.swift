import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    private let privacyPolicyURL = URL(string: "https://gotit.app/privacy")!
    private let supportURL = URL(string: "mailto:broman.89@gmail.com?subject=Support%20Request")!

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @EnvironmentObject private var proAccess: ProAccessController
    @AppStorage(AppSettings.selectedLanguageKey) private var selectedLanguage = AppLanguage.system.rawValue
    @AppStorage(AppSettings.hideOnboardingKey) private var hideOnboarding = false
    @AppStorage(AppSettings.comicVineAPIKeyKey) private var comicVineAPIKey = ""
    @AppStorage(AppSettings.theGamesDBAPIKeyKey) private var theGamesDBAPIKey = ""
    @AppStorage(AppSettings.googleBooksAPIKeyKey) private var googleBooksAPIKey = ""
    @AppStorage(AppSettings.discogsConsumerKeyKey) private var discogsConsumerKey = ""
    @AppStorage(AppSettings.discogsConsumerSecretKey) private var discogsConsumerSecret = ""
    @AppStorage(AppSettings.defaultOwnershipFilterKey) private var defaultOwnershipFilter = ItemOwnershipFilter.all.rawValue
    @AppStorage(AppSettings.defaultQuickFilterKey) private var defaultQuickFilter = ItemQuickFilter.all.rawValue
    @AppStorage(AppSettings.defaultSortOptionKey) private var defaultSortOption = ItemSortOption.newest.rawValue
    @AppStorage(AppSettings.defaultDisplayModeKey) private var defaultDisplayMode = ItemDisplayMode.grid.rawValue
    @State private var isGeneralSectionExpanded = false
    @State private var isUsageGuideExpanded = false
    @State private var isAPISectionExpanded = false
    @State private var isBackupSectionExpanded = false
    @State private var isProSectionExpanded = false
    @State private var isPrivacySectionExpanded = false
    @State private var isAboutSectionExpanded = false
    @State private var isEditingAPIKeys = false
    @State private var exportURL: URL?
    @State private var isImportingLibrary = false
    @State private var isImportingCSV = false
    @State private var csvImportURL: URL?
    @State private var pendingImportURL: URL?
    @State private var importFailed = false
    @State private var csvImportFailed = false
    @State private var isShowingPaywall = false
    @State private var paywallMessage = L10n.Pro.subtitle

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        SettingsHeaderView()
                        languageSection
                        generalSection
                        onboardingSection
                        proSection
                        apiSection
                        backupSection
                        usageGuideSection
                        privacySection
                        aboutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Settings.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ComicTheme.paper, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.Common.save) {
                        dismiss()
                    }
                    .font(.headline.weight(.black))
                }
            }
            .fileImporter(
                isPresented: $isImportingLibrary,
                allowedContentTypes: [UTType(filenameExtension: "json") ?? .item],
                allowsMultipleSelection: false
            ) { result in
                guard case .success(let urls) = result, let url = urls.first else { return }
                pendingImportURL = url
            }
            .fileImporter(
                isPresented: $isImportingCSV,
                allowedContentTypes: [UTType(filenameExtension: "csv") ?? .commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                guard case .success(let urls) = result, let url = urls.first else { return }
                csvImportURL = url
            }
            .sheet(isPresented: csvDestinationBinding) {
                CSVImportDestinationPicker(categories: libraryController.categories) { category in
                    importCSV(into: category)
                }
            }
            .sheet(isPresented: $isShowingPaywall) {
                ProPaywallView(message: paywallMessage)
            }
            .alert(L10n.Settings.importLibraryTitle, isPresented: importConfirmationBinding) {
                Button(L10n.Common.cancel, role: .cancel) {
                    pendingImportURL = nil
                }

                Button(L10n.Settings.importLibraryConfirm, role: .destructive) {
                    guard let pendingImportURL else { return }
                    let didImport = libraryController.importLibrary(from: pendingImportURL)
                    self.pendingImportURL = nil
                    importFailed = !didImport
                }
            } message: {
                Text(L10n.Settings.importLibraryMessage)
            }
            .alert(L10n.Settings.importLibraryFailedTitle, isPresented: $importFailed) {
                Button(L10n.Common.cancel, role: .cancel) {}
            } message: {
                Text(L10n.Settings.importLibraryFailedMessage)
            }
            .alert(L10n.Settings.importCSVFailedTitle, isPresented: $csvImportFailed) {
                Button(L10n.Common.cancel, role: .cancel) {}
            } message: {
                Text(L10n.Settings.importCSVFailedMessage)
            }
        }
    }

    private var importConfirmationBinding: Binding<Bool> {
        Binding(
            get: { pendingImportURL != nil },
            set: { isPresented in
                if !isPresented {
                    pendingImportURL = nil
                }
            }
        )
    }

    private var csvDestinationBinding: Binding<Bool> {
        Binding(
            get: { csvImportURL != nil },
            set: { isPresented in
                if !isPresented {
                    csvImportURL = nil
                }
            }
        )
    }

    private func importCSV(into category: CollectionCategory) {
        guard let csvImportURL else { return }

        do {
            let items = try CSVItemImportController().importItems(from: csvImportURL, template: category.template)
            libraryController.addItems(items, toCategory: category.id)
            self.csvImportURL = nil
        } catch {
            self.csvImportURL = nil
            csvImportFailed = true
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsSectionTitle(
                systemName: "globe",
                title: L10n.Settings.languageTitle
            )

            ComicSegmentedControl(
                options: AppLanguage.allCases,
                selection: selectedLanguageBinding,
                title: { $0.title }
            )
        }
        .padding(16)
        .comicPanel()
    }

    private var selectedLanguageBinding: Binding<AppLanguage> {
        Binding(
            get: { AppLanguage(rawValue: selectedLanguage) ?? .system },
            set: { selectedLanguage = $0.rawValue }
        )
    }

    private var generalSection: some View {
        DisclosureGroup(isExpanded: $isGeneralSectionExpanded) {
            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.Settings.generalHint)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)

                SettingsPickerRow(
                    title: L10n.Settings.defaultOwnershipFilter,
                    systemName: "checkmark.seal.fill",
                    options: ItemOwnershipFilter.allCases,
                    selection: defaultOwnershipBinding,
                    optionTitle: { $0.title }
                )

                SettingsPickerRow(
                    title: L10n.Settings.defaultQuickFilter,
                    systemName: "line.3.horizontal.decrease.circle.fill",
                    options: ItemQuickFilter.allCases,
                    selection: defaultQuickFilterBinding,
                    optionTitle: { $0.title }
                )

                SettingsPickerRow(
                    title: L10n.Settings.defaultSort,
                    systemName: "arrow.up.arrow.down.square.fill",
                    options: ItemSortOption.allCases,
                    selection: defaultSortBinding,
                    optionTitle: { $0.title }
                )

                SettingsPickerRow(
                    title: L10n.Settings.defaultDisplay,
                    systemName: "square.grid.2x2.fill",
                    options: ItemDisplayMode.allCases,
                    selection: defaultDisplayBinding,
                    optionTitle: { $0.title }
                )
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(
                systemName: "slider.horizontal.3",
                title: L10n.Settings.generalTitle
            )
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var defaultOwnershipBinding: Binding<ItemOwnershipFilter> {
        Binding(
            get: { ItemOwnershipFilter(rawValue: defaultOwnershipFilter) ?? .all },
            set: { defaultOwnershipFilter = $0.rawValue }
        )
    }

    private var defaultQuickFilterBinding: Binding<ItemQuickFilter> {
        Binding(
            get: { ItemQuickFilter(rawValue: defaultQuickFilter) ?? .all },
            set: { defaultQuickFilter = $0.rawValue }
        )
    }

    private var defaultSortBinding: Binding<ItemSortOption> {
        Binding(
            get: { ItemSortOption(rawValue: defaultSortOption) ?? .newest },
            set: { defaultSortOption = $0.rawValue }
        )
    }

    private var defaultDisplayBinding: Binding<ItemDisplayMode> {
        Binding(
            get: { ItemDisplayMode(rawValue: defaultDisplayMode) ?? .grid },
            set: { defaultDisplayMode = $0.rawValue }
        )
    }

    private var onboardingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsSectionTitle(
                systemName: "sparkles.rectangle.stack.fill",
                title: L10n.Settings.onboardingTitle
            )

            Toggle(isOn: $hideOnboarding) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Settings.hideOnboarding)
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink)

                    Text(L10n.Settings.hideOnboardingHint)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ComicTheme.ink.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(ComicTheme.yellow)
            .colorScheme(.light)
            .padding(12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
        .padding(16)
        .comicPanel()
    }

    private var proSection: some View {
        DisclosureGroup(isExpanded: $isProSectionExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                SettingsGuideRow(
                    systemName: proAccess.isProUnlocked ? "checkmark.seal.fill" : "lock.open.fill",
                    title: proAccess.isProUnlocked ? L10n.Pro.unlocked : L10n.Pro.title,
                    description: L10n.Pro.subtitle
                )

                if !proAccess.isProUnlocked {
                    Button {
                        paywallMessage = L10n.Pro.subtitle
                        isShowingPaywall = true
                    } label: {
                        SettingsActionLabel(title: L10n.Pro.unlock, systemName: "sparkles")
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task {
                            await proAccess.redeemOfferCode()
                        }
                    } label: {
                        SettingsActionLabel(title: L10n.Pro.redeemCode, systemName: "giftcard.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "crown.fill", title: L10n.Pro.title)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var usageGuideSection: some View {
        DisclosureGroup(isExpanded: $isUsageGuideExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                SettingsGuideRow(systemName: "square.grid.2x2.fill", title: L10n.Settings.guideCollectionsTitle, description: L10n.Settings.guideCollectionsBody)
                SettingsGuideRow(systemName: "tray.full.fill", title: L10n.Settings.guideShelvesTitle, description: L10n.Settings.guideShelvesBody)
                SettingsGuideRow(systemName: "photo.fill", title: L10n.Settings.guideCoversTitle, description: L10n.Settings.guideCoversBody)
                SettingsGuideRow(systemName: "checkmark.seal.fill", title: L10n.Settings.guideTrackingTitle, description: L10n.Settings.guideTrackingBody)
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "questionmark.circle.fill", title: L10n.Settings.usageGuideTitle)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var apiSection: some View {
        DisclosureGroup(isExpanded: $isAPISectionExpanded) {
            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.Settings.apiPrivacyBody)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    isEditingAPIKeys.toggle()
                } label: {
                    Label(
                        isEditingAPIKeys ? L10n.Settings.hideAPIKeys : L10n.Settings.editAPIKeys,
                        systemImage: isEditingAPIKeys ? "eye.slash.fill" : "pencil"
                    )
                    .font(.caption.weight(.black))
                    .foregroundStyle(ComicTheme.ink)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(ComicTheme.yellow)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(ComicTheme.ink, lineWidth: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                .buttonStyle(.plain)

                apiKeySection(
                    systemName: "book.closed.fill",
                    title: L10n.Settings.googleBooksTitle,
                    placeholder: L10n.Settings.googleBooksAPIKeyPlaceholder,
                    text: $googleBooksAPIKey,
                    isConfigured: !googleBooksAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    guideBody: L10n.Settings.googleBooksGuideBody,
                    linkTitle: L10n.Settings.googleBooksOpenAPIPage,
                    linkURL: URL(string: "https://developers.google.com/books/docs/v1/using")!
                )

                apiKeySection(
                    systemName: "book.closed.fill",
                    title: L10n.Settings.comicVineTitle,
                    placeholder: L10n.Settings.comicVineAPIKeyPlaceholder,
                    text: $comicVineAPIKey,
                    isConfigured: !comicVineAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    guideBody: L10n.Settings.comicVineGuideBody,
                    linkTitle: L10n.Settings.comicVineOpenAPIPage,
                    linkURL: URL(string: "https://comicvine.gamespot.com/api/")!
                )

                apiKeySection(
                    systemName: "gamecontroller.fill",
                    title: L10n.Settings.theGamesDBTitle,
                    placeholder: L10n.Settings.theGamesDBAPIKeyPlaceholder,
                    text: $theGamesDBAPIKey,
                    isConfigured: !theGamesDBAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    guideBody: L10n.Settings.theGamesDBGuideBody,
                    linkTitle: L10n.Settings.theGamesDBOpenAPIPage,
                    linkURL: URL(string: "https://api.thegamesdb.net/")!
                )

                discogsAPISection
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "key.fill", title: L10n.Settings.apiSectionTitle)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var backupSection: some View {
        DisclosureGroup(isExpanded: $isBackupSectionExpanded) {
            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.Settings.backupBody)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                SettingsGuideRow(
                    systemName: "exclamationmark.shield.fill",
                    title: L10n.Settings.backupReminderTitle,
                    description: L10n.Settings.backupReminderBody
                )

                Button {
                    exportURL = libraryController.exportLibrary()
                } label: {
                    SettingsActionLabel(title: L10n.Settings.exportLibrary, systemName: "square.and.arrow.up.fill")
                }
                .buttonStyle(.plain)

                if let exportURL {
                    ShareLink(item: exportURL) {
                        SettingsActionLabel(title: L10n.Settings.shareExportedLibrary, systemName: "paperplane.fill")
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    isImportingLibrary = true
                } label: {
                    SettingsActionLabel(title: L10n.Settings.importLibrary, systemName: "square.and.arrow.down.fill")
                }
                .buttonStyle(.plain)

                SettingsGuideRow(
                    systemName: "tablecells.fill",
                    title: L10n.Settings.importCSV,
                    description: L10n.Settings.importCSVBody
                )

                Button {
                    guard proAccess.isProUnlocked else {
                        paywallMessage = L10n.Pro.featureLimitMessage
                        isShowingPaywall = true
                        return
                    }
                    isImportingCSV = true
                } label: {
                    SettingsActionLabel(title: L10n.Settings.importCSV, systemName: "doc.badge.plus")
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "externaldrive.fill", title: L10n.Settings.backupTitle)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var privacySection: some View {
        DisclosureGroup(isExpanded: $isPrivacySectionExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                SettingsGuideRow(systemName: "lock.fill", title: L10n.Settings.privacyLocalTitle, description: L10n.Settings.privacyLocalBody)
                SettingsGuideRow(systemName: "key.fill", title: L10n.Settings.privacyAPIKeysTitle, description: L10n.Settings.privacyAPIKeysBody)
                SettingsGuideRow(systemName: "camera.fill", title: L10n.Settings.privacyMediaTitle, description: L10n.Settings.privacyMediaBody)
                SettingsGuideRow(systemName: "network", title: L10n.Settings.privacyNetworkTitle, description: L10n.Settings.privacyNetworkBody)
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "hand.raised.fill", title: L10n.Settings.privacyTitle)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var aboutSection: some View {
        DisclosureGroup(isExpanded: $isAboutSectionExpanded) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.Settings.aboutBody)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                SettingsInfoRow(
                    systemName: "number.circle.fill",
                    title: L10n.Settings.appVersionTitle,
                    value: appVersion
                )

                SettingsLinkButton(title: L10n.Settings.privacyPolicy, url: privacyPolicyURL)
                SettingsLinkButton(title: L10n.Settings.contactSupport, url: supportURL)

                Button {
                    exportURL = libraryController.exportLibrary()
                } label: {
                    SettingsActionLabel(title: L10n.Settings.backupShortcut, systemName: "externaldrive.fill")
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "info.circle.fill", title: L10n.Settings.aboutTitle)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var discogsAPISection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(
                systemName: "record.circle.fill",
                title: L10n.Settings.discogsTitle
            )

            SettingsAPIStatusView(isConfigured: discogsCredentialsConfigured)

            if isEditingAPIKeys {
                SettingsSecureField(placeholder: L10n.Settings.discogsConsumerKeyPlaceholder, text: $discogsConsumerKey)

                SettingsSecureField(placeholder: L10n.Settings.discogsConsumerSecretPlaceholder, text: $discogsConsumerSecret)
            }

            Text(L10n.Settings.discogsGuideBody)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ComicTheme.ink.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            SettingsLinkButton(title: L10n.Settings.discogsOpenAPIPage, url: URL(string: "https://www.discogs.com/developers")!)
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }

    private var discogsCredentialsConfigured: Bool {
        !discogsConsumerKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !discogsConsumerSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func apiKeySection(
        systemName: String,
        title: String,
        placeholder: String,
        text: Binding<String>,
        isConfigured: Bool,
        guideBody: String,
        linkTitle: String,
        linkURL: URL
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(
                systemName: systemName,
                title: title
            )

            SettingsAPIStatusView(isConfigured: isConfigured)

            if isEditingAPIKeys {
                SettingsSecureField(placeholder: placeholder, text: text)
            }

            Text(guideBody)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(ComicTheme.ink.opacity(0.82))
                .fixedSize(horizontal: false, vertical: true)

            SettingsLinkButton(title: linkTitle, url: linkURL)
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct SettingsHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Settings.eyebrow.uppercased())
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Text(L10n.Settings.title.uppercased().vintageSafe)
                .font(ComicTheme.displayFont)
                .foregroundStyle(ComicTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .comicPanel(fill: ComicTheme.yellow)
    }
}

private struct SettingsSectionTitle: View {
    let systemName: String
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.red)

            Text(title.uppercased())
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)
        }
    }
}

private struct SettingsPickerRow<Option: Identifiable & Hashable>: View {
    let title: String
    let systemName: String
    let options: [Option]
    @Binding var selection: Option
    let optionTitle: (Option) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title.uppercased().vintageSafe, systemImage: systemName)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.76))

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
                    Text(optionTitle(selection).uppercased().vintageSafe)
                        .font(.headline.weight(.black))
                        .foregroundStyle(ComicTheme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.black))
                        .foregroundStyle(ComicTheme.ink.opacity(0.65))
                }
                .padding(12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(ComicTheme.ink, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .shadow(color: ComicTheme.ink, radius: 0, x: 3, y: 3)
            }
        }
        .padding(12)
        .background(ComicTheme.paper)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct SettingsSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(ComicTheme.ink.opacity(0.72)))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(ComicTheme.bodyFont)
            .foregroundStyle(ComicTheme.ink)
            .tint(ComicTheme.blue)
            .padding(14)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: ComicTheme.ink, radius: 0, x: 3, y: 3)
    }
}

private struct SettingsAPIStatusView: View {
    let isConfigured: Bool

    var body: some View {
        Label(
            isConfigured ? L10n.Settings.apiConfigured : L10n.Settings.apiNotConfigured,
            systemImage: isConfigured ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
        )
        .font(.caption.weight(.black))
        .foregroundStyle(ComicTheme.ink)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(isConfigured ? ComicTheme.green.opacity(0.35) : ComicTheme.yellow.opacity(0.6))
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(ComicTheme.ink, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct SettingsLinkButton: View {
    let title: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 8) {
                Image(systemName: "safari.fill")
                Text(title.uppercased())
            }
            .font(.caption.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(ComicTheme.yellow)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}

private struct SettingsActionLabel: View {
    let title: String
    let systemName: String

    var body: some View {
        Label(title.uppercased(), systemImage: systemName)
            .font(.caption.weight(.black))
            .foregroundStyle(ComicTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(ComicTheme.yellow)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(ComicTheme.ink, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .shadow(color: ComicTheme.ink, radius: 0, x: 3, y: 3)
    }
}

private struct SettingsInfoRow: View {
    let systemName: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.red)
                .frame(width: 28)

            Text(title)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.ink)

            Spacer(minLength: 12)

            Text(value)
                .font(.caption.weight(.black))
                .foregroundStyle(ComicTheme.ink.opacity(0.68))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
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

private struct SettingsGuideRow: View {
    let systemName: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemName)
                .font(.headline.weight(.black))
                .foregroundStyle(ComicTheme.red)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(ComicTheme.ink)

                Text(description)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }
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

private struct CSVImportDestinationPicker: View {
    @Environment(\.dismiss) private var dismiss
    let categories: [CollectionCategory]
    let onSelect: (CollectionCategory) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                HalftoneBackground()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(categories.filter(\.allowsTopLevelItems)) { category in
                            Button {
                                onSelect(category)
                                dismiss()
                            } label: {
                                HStack(spacing: 12) {
                                    CategoryIconView(category: category, size: 44, symbolSize: 24)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(category.title.uppercased().vintageSafe)
                                            .font(.headline.weight(.black))
                                            .foregroundStyle(ComicTheme.ink)
                                            .lineLimit(2)

                                        Text(category.subtitle)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(ComicTheme.ink.opacity(0.68))
                                            .lineLimit(2)
                                    }

                                    Spacer(minLength: 0)
                                }
                                .padding(14)
                                .comicPanel(fill: ComicTheme.panel)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.Settings.importCSVDestinationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}
