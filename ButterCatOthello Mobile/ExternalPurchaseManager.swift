import StoreKit

/// 韓国App Store向け外部購入（StoreKit External Purchase）を管理するマネージャー
@MainActor
final class ExternalPurchaseManager: ObservableObject {
    static let shared = ExternalPurchaseManager()

    @Published private(set) var canShowExternalPurchase = false

    private init() {}

    /// 外部購入が利用可能かチェックする
    @available(iOS 17.4, *)
    func checkAvailability() async {
        guard AppStore.canMakePayments else {
            canShowExternalPurchase = false
            return
        }
        canShowExternalPurchase = await ExternalPurchase.canPresent
    }

    /// Apple の通知シートを表示し、ユーザーが承諾した場合にトークンを返す
    /// - Returns: 外部購入トークン（ユーザーがキャンセルした場合は nil）
    @available(iOS 17.4, *)
    func presentNoticeAndGetToken() async throws -> String? {
        guard await ExternalPurchase.canPresent else { return nil }

        let result = try await ExternalPurchase.presentNoticeSheet()
        switch result {
        case .continuedWithExternalPurchaseToken(let token):
            return token
        default:
            return nil
        }
    }
}
