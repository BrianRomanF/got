import Foundation
import StoreKit
import UIKit

@MainActor
final class ProAccessController: ObservableObject {
    static let proProductID = "com.brianroman.gotit.pro"
    static let freeCollectionLimit = 1
    static let freeItemLimit = 10

    @Published private(set) var isProUnlocked: Bool
    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        isProUnlocked = AppSettings.isProUnlocked
        updatesTask = observeTransactions()

        Task {
            await refresh()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func refresh() async {
        await loadProduct()
        await refreshEntitlements()
    }

    func purchasePro() async {
        isLoading = true
        errorMessage = nil
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
                unlockPro()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func redeemOfferCode() async {
        errorMessage = nil

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else {
            errorMessage = L10n.Pro.redeemUnavailable
            return
        }

        do {
            try await AppStore.presentOfferCodeRedeemSheet(in: scene)
            await refreshEntitlements()
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

    private func refreshEntitlements() async {
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
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                guard let transaction = try? self.verifiedTransaction(from: result) else { continue }

                if transaction.productID == Self.proProductID {
                    self.unlockPro()
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

    private func unlockPro() {
        isProUnlocked = true
        AppSettings.isProUnlocked = true
    }
}

private enum StoreKitError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        L10n.Pro.verificationFailed
    }
}
