import GoogleMobileAds
import UIKit

@MainActor
final class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()

    // MARK: - Ad Unit IDs
    static let bannerAdUnitID = "ca-app-pub-1615601076718034/9813212424"
    static let interstitialAdUnitID = "ca-app-pub-1615601076718034/4560885746"

    // 一時的に無効化（再有効化するには true に戻す）
    static let interstitialEnabled = false

    // MARK: - Interstitial
    @Published private(set) var interstitialAd: InterstitialAd?

    private override init() {
        super.init()
    }

    /// SDK初期化
    func configure() {
        Task {
            await MobileAds.shared.start()
            self.loadInterstitial()
        }
    }

    /// インタースティシャル広告を読み込み
    func loadInterstitial() {
        guard Self.interstitialEnabled else { return }
        InterstitialAd.load(
            with: Self.interstitialAdUnitID,
            request: Request()
        ) { [weak self] ad, error in
            Task { @MainActor in
                if let error {
                    print("[AdMob] Interstitial load error: \(error.localizedDescription)")
                    return
                }
                self?.interstitialAd = ad
            }
        }
    }

    /// インタースティシャル広告を表示（表示後に自動リロード）
    func showInterstitial() {
        guard Self.interstitialEnabled else { return }
        guard let ad = interstitialAd,
              let root = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first?.rootViewController else {
            loadInterstitial()
            return
        }
        ad.present(from: root)
        interstitialAd = nil
        loadInterstitial()
    }
}
