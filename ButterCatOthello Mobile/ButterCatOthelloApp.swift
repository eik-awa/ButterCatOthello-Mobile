import SwiftUI

@main
struct ButterCatOthelloApp: App {
    init() {
        AdMobManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            StartView()
                .onAppear {
                    AudioManager.shared.playBGM()
                }
        }
    }
}
