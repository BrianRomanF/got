import CloudKit
import SwiftUI

struct SettingsSyncSectionView: View {
    @EnvironmentObject private var libraryController: CollectionLibraryController
    @EnvironmentObject private var syncStateController: LibrarySyncStateController
    @StateObject private var cloudKitCoordinator: CloudKitSyncCoordinator
    @State private var isShowingBackupConfirmation = false
    @State private var backupMessage: String?
    @State private var syncPlan: CloudKitSyncPlan?
    @State private var isPreparingSync = false
    @State private var syncErrorMessage: String?

    init() {
        _cloudKitCoordinator = StateObject(
            wrappedValue: CloudKitSyncCoordinator(
                syncStateController: .shared
            )
        )
    }

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.Settings.syncBody)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ComicTheme.ink.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)

                SettingsGuideRow(
                    systemName: "icloud.fill",
                    title: L10n.Settings.syncStatusTitle,
                    description: statusDescription
                )

                if cloudKitCoordinator.accountStatus != .available,
                   !cloudKitCoordinator.isCheckingAccount {
                    Button {
                        Task {
                            await cloudKitCoordinator.refreshAccountStatus()
                        }
                    } label: {
                        SettingsActionLabel(
                            title: L10n.Settings.syncCheckConnection,
                            systemName: "arrow.clockwise.icloud"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    isShowingBackupConfirmation = true
                } label: {
                    SettingsActionLabel(title: L10n.Settings.syncBackupNow, systemName: "shield.lefthalf.filled")
                }
                .buttonStyle(.plain)

                Button {
                    prepareSync()
                } label: {
                    SettingsActionLabel(title: L10n.Settings.syncNow, systemName: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.plain)
                .disabled(isPreparingSync || cloudKitCoordinator.accountStatus != .available)
                .opacity(isPreparingSync || cloudKitCoordinator.accountStatus != .available ? 0.45 : 1)

                if isPreparingSync {
                    ProgressView()
                        .tint(ComicTheme.ink)
                }

                if let backupMessage {
                    Text(backupMessage)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(ComicTheme.green)
                }
            }
            .padding(.top, 12)
        } label: {
            SettingsSectionTitle(systemName: "icloud.fill", title: L10n.Settings.syncTitle)
        }
        .tint(ComicTheme.ink)
        .padding(16)
        .comicPanel()
        .task {
            await cloudKitCoordinator.refreshAccountStatus()
        }
        .alert(L10n.Settings.syncBackupConfirmTitle, isPresented: $isShowingBackupConfirmation) {
            Button(L10n.Common.cancel, role: .cancel) {}
            Button(L10n.Settings.syncBackupNow) {
                createBackup()
            }
        } message: {
            Text(L10n.Settings.syncBackupConfirmMessage)
        }
        .confirmationDialog(
            L10n.Settings.syncReviewTitle,
            isPresented: syncPlanBinding,
            titleVisibility: .visible
        ) {
            if let syncPlan {
                switch syncPlan.kind {
                case .uploadLocal:
                    Button(L10n.Settings.syncUploadLocal) {
                        execute(plan: syncPlan, decision: .uploadLocal)
                    }
                case .downloadRemote:
                    Button(L10n.Settings.syncDownloadRemote) {
                        execute(plan: syncPlan, decision: .downloadRemote)
                    }
                case .conflict:
                    Button(L10n.Settings.syncKeepLocal) {
                        execute(plan: syncPlan, decision: .uploadLocal)
                    }
                    Button(L10n.Settings.syncKeepRemote) {
                        execute(plan: syncPlan, decision: .downloadRemote)
                    }
                    Button(L10n.Settings.syncMerge) {
                        execute(plan: syncPlan, decision: .merge)
                    }
                case .noChanges:
                    Button(L10n.Common.save, role: .cancel) {}
                case .merge:
                    Button(L10n.Common.cancel, role: .cancel) {}
                }
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(syncPlan?.message ?? "")
        }
        .alert(L10n.Settings.syncFailedTitle, isPresented: syncErrorBinding) {
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(syncErrorMessage ?? L10n.Settings.syncStatusFailed)
        }
    }

    private var statusDescription: String {
        if cloudKitCoordinator.isCheckingAccount {
            return L10n.Settings.syncStatusSyncing
        }

        if cloudKitCoordinator.accountStatus != .available {
            return L10n.Settings.syncStatusUnavailable
        }

        return switch syncStateController.state.status {
        case .unavailable:
            L10n.Settings.syncStatusUnavailable
        case .idle:
            L10n.Settings.syncStatusIdle
        case .syncing:
            L10n.Settings.syncStatusSyncing
        case .synced:
            L10n.Settings.syncStatusSynced
        case .pendingChanges:
            L10n.Settings.syncStatusPending
        case .offline:
            L10n.Settings.syncStatusOffline
        case .conflict:
            L10n.Settings.syncStatusConflict
        case .failed:
            syncStateController.state.lastErrorMessage ?? L10n.Settings.syncStatusFailed
        }
    }

    private func createBackup() {
        guard let backup = libraryController.createSyncBackup() else {
            backupMessage = L10n.Settings.syncBackupFailed
            return
        }

        backupMessage = String(format: L10n.Settings.syncBackupCreated, backup.itemCount)
    }

    private func prepareSync() {
        isPreparingSync = true
        Task {
            do {
                syncPlan = try await cloudKitCoordinator.preparePlan(localCategories: libraryController.categories)
            } catch {
                syncErrorMessage = error.localizedDescription
            }
            isPreparingSync = false
        }
    }

    private func execute(plan: CloudKitSyncPlan, decision: CloudKitSyncPlanKind) {
        guard libraryController.createSyncBackup() != nil else {
            syncErrorMessage = L10n.Settings.syncBackupFailed
            return
        }

        Task {
            do {
                if let remoteCategories = try await cloudKitCoordinator.execute(
                    plan: plan,
                    decision: decision,
                    localCategories: libraryController.categories
                ) {
                    libraryController.replaceCategoriesFromSync(remoteCategories)
                }
                syncPlan = nil
            } catch {
                syncErrorMessage = error.localizedDescription
            }
        }
    }

    private var syncPlanBinding: Binding<Bool> {
        Binding(
            get: { syncPlan != nil },
            set: { isPresented in
                if !isPresented { syncPlan = nil }
            }
        )
    }

    private var syncErrorBinding: Binding<Bool> {
        Binding(
            get: { syncErrorMessage != nil },
            set: { isPresented in
                if !isPresented { syncErrorMessage = nil }
            }
        )
    }
}
