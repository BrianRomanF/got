import Foundation
import StoreKit
import UIKit

@MainActor
final class ProAccessController: ObservableObject {
    static let proProductID = "com.brianroman.gotit.pro"
    static let freeCollectionLimit = 1
    static let freeItemLimit = 10

    private static var isLocalProEnabled: Bool {
        #if DEBUG && LOCAL_DEVICE_BUILD
        true
        #else
        false
        #endif
    }

    @Published private(set) var isProUnlocked: Bool
    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var statusMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        isProUnlocked = Self.isLocalProEnabled || AppSettings.isProUnlocked
        if !Self.isLocalProEnabled {
            updatesTask = observeTransactions()
        }

        Task {
            await refresh()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refresh() async {
        guard !activateLocalProIfEnabled() else { return }
        await loadProduct()
        await refreshEntitlements()
    }

    func purchasePro() async {
        guard !activateLocalProIfEnabled() else { return }
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        defer { isLoading = false }

        do {
            let product: Product?
            if let loadedProduct = self.product {
                product = loadedProduct
            } else {
                product = try await Product.products(for: [Self.proProductID]).first
                self.product = product
            }

            guard let product else {
                errorMessage = L10n.Pro.unavailable
                return
            }

            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verifiedTransaction(from: verification)
                unlockPro(message: L10n.Pro.purchaseSuccess)
                await transaction.finish()
            case .userCancelled:
                statusMessage = L10n.Pro.purchaseCancelled
            case .pending:
                statusMessage = L10n.Pro.purchasePending
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        guard !activateLocalProIfEnabled() else { return }
        isLoading = true
        errorMessage = nil
        statusMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            let restoredPro = await refreshEntitlements()
            statusMessage = restoredPro ? L10n.Pro.restoreSuccess : L10n.Pro.restoreEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func redeemOfferCode() async {
        guard !activateLocalProIfEnabled() else { return }
        errorMessage = nil
        statusMessage = nil

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            errorMessage = L10n.Pro.redeemUnavailable
            return
        }

        do {
            try await AppStore.presentOfferCodeRedeemSheet(in: scene)
            let redeemedPro = await refreshEntitlements()
            statusMessage = redeemedPro ? L10n.Pro.purchaseSuccess : L10n.Pro.redeemCheck
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func canCreateCategory(currentCount: Int) -> Bool {
        isProUnlocked || currentCount < Self.freeCollectionLimit
    }

    func canAddItems(currentTotal: Int, adding count: Int = 1) -> Bool {
        isProUnlocked || currentTotal + count <= Self.freeItemLimit
    }

    private func loadProduct() async {
        do {
            product = try await Product.products(for: [Self.proProductID]).first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    private func refreshEntitlements() async -> Bool {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? verifiedTransaction(from: result) else { continue }
            if transaction.productID == Self.proProductID {
                hasPro = true
            }
        }

        if hasPro {
            unlockPro()
        } else {
            isProUnlocked = false
            AppSettings.isProUnlocked = false
        }

        return hasPro
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? self.verifiedTransaction(from: result) else { continue }

                if transaction.productID == Self.proProductID {
                    self.unlockPro(message: L10n.Pro.purchaseSuccess)
                }

                await transaction.finish()
            }
        }
    }

    private func verifiedTransaction<T>(from result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let transaction):
            return transaction
        case .unverified:
            throw StoreKitError.failedVerification
        }
    }

    private func unlockPro(message: String? = nil) {
        isProUnlocked = true
        if !Self.isLocalProEnabled {
            AppSettings.isProUnlocked = true
        }

        if let message {
            statusMessage = message
        }
    }

    private func activateLocalProIfEnabled() -> Bool {
        guard Self.isLocalProEnabled else { return false }
        errorMessage = nil
        unlockPro(message: L10n.Pro.unlocked)
        return true
    }
}

private enum StoreKitError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        L10n.Pro.verificationFailed
    }
}
