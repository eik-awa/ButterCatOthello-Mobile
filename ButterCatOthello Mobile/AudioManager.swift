import AVFoundation

final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var bgmPlayer: AVAudioPlayer?
    private var sfxPlayer: AVAudioPlayer?

    private static let bgmMutedKey = "AudioManager.bgmMuted"
    private static let seMutedKey  = "AudioManager.seMuted"

    @Published var isBGMMuted: Bool {
        didSet { UserDefaults.standard.set(isBGMMuted, forKey: Self.bgmMutedKey) }
    }
    @Published var isSEMuted: Bool {
        didSet { UserDefaults.standard.set(isSEMuted, forKey: Self.seMutedKey) }
    }

    private init() {
        self.isBGMMuted = UserDefaults.standard.bool(forKey: Self.bgmMutedKey)
        self.isSEMuted  = UserDefaults.standard.bool(forKey: Self.seMutedKey)
    }

    // MARK: - BGM

    func playBGM() {
        guard !isBGMMuted else { return }
        guard bgmPlayer == nil || bgmPlayer?.isPlaying == false else { return }
        guard let url = Bundle.main.url(forResource: "theme", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
            bgmPlayer?.numberOfLoops = -1 // 無限ループ
            bgmPlayer?.volume = 0.4
            bgmPlayer?.play()
        } catch {}
    }

    func stopBGM() {
        bgmPlayer?.stop()
        bgmPlayer = nil
    }

    func toggleBGM() {
        isBGMMuted.toggle()
        if isBGMMuted {
            stopBGM()
        } else {
            playBGM()
        }
    }

    func toggleSE() {
        isSEMuted.toggle()
    }

    // MARK: - SFX

    func playMeow() {
        guard !isSEMuted else { return }
        guard let url = Bundle.main.url(forResource: "meow", withExtension: "mp3") else { return }
        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.volume = 0.6
            sfxPlayer?.play()
        } catch {}
    }
}
