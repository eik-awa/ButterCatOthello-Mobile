import SwiftUI

@main
struct ButterCatOthelloApp: App {
    init() {
        AdMobManager.shared.configure()
        print("[DebugBadge] Identifier: \(DebugDeviceConfig.persistentDeviceID)")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                StartView()
                    .onAppear {
                        AudioManager.shared.playBGM()
                    }
                if DebugDeviceConfig.isDebugDevice {
                    DebugBadgeOverlay()
                }
            }
        }
    }
}

private struct DebugBadgeOverlay: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 4, height: 4)
                    .rotationEffect(.degrees(45))
                    .padding(20)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
