import AudioToolbox
import AVFoundation
import Combine

final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    // MARK: - Published State

    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: UserDefaultsKeys.musicEnabled)
            updateMusicState()
        }
    }

    @Published var isSoundEffectsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEffectsEnabled, forKey: UserDefaultsKeys.soundEffectsEnabled)
        }
    }

    @Published var allowOwnMusic: Bool {
        didSet {
            UserDefaults.standard.set(allowOwnMusic, forKey: UserDefaultsKeys.allowOwnMusic)
            configureAudioSession()
        }
    }

    // MARK: - Private Properties

    private var musicPlayer: AVAudioPlayer?
    private var menuMusicPlayer: AVAudioPlayer?
    private var currentGameMusicIndex: Int = 0

    private enum UserDefaultsKeys {
        static let musicEnabled = "soundManager.musicEnabled"
        static let soundEffectsEnabled = "soundManager.soundEffectsEnabled"
        static let allowOwnMusic = "soundManager.allowOwnMusic"
    }

    private let gameMusicFiles = ["game_music_1", "game_music_2"]
    private let menuMusicFile = "menu_music"

    // MARK: - Sound Effect Types

    enum SoundEffect: String, CaseIterable {
        case squareTap = "tap"
        case success = "success"
        case failure = "failure"
        case gameOver = "game_over"
        case combo = "combo"
        case levelUp = "level_up"
    }

    // MARK: - Initialization

    private init() {
        self.isMusicEnabled = UserDefaults.standard.object(forKey: UserDefaultsKeys.musicEnabled) == nil
            ? true
            : UserDefaults.standard.bool(forKey: UserDefaultsKeys.musicEnabled)
        self.isSoundEffectsEnabled = UserDefaults.standard.object(forKey: UserDefaultsKeys.soundEffectsEnabled) == nil
            ? true
            : UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEffectsEnabled)
        self.allowOwnMusic = UserDefaults.standard.object(forKey: UserDefaultsKeys.allowOwnMusic) == nil
            ? false
            : UserDefaults.standard.bool(forKey: UserDefaultsKeys.allowOwnMusic)

        configureAudioSession()
        setupNotifications()
    }

    // MARK: - Audio Session Configuration

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            if allowOwnMusic {
                try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            } else {
                try session.setCategory(.soloAmbient, mode: .default, options: [])
            }

            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    @objc private func handleAppDidBecomeActive() {
        updateMusicState()
    }

    @objc private func handleAppWillResignActive() {
        pauseAllMusic()
    }

    // MARK: - Music Control

    func startGameMusic() {
        guard isMusicEnabled && !allowOwnMusic else { return }

        stopMenuMusic()

        currentGameMusicIndex = Int.random(in: 0..<gameMusicFiles.count)
        let musicFile = gameMusicFiles[currentGameMusicIndex]

        musicPlayer = createAudioPlayer(for: musicFile, loops: -1)
        musicPlayer?.volume = 0.5
        musicPlayer?.play()
    }

    func stopGameMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func startMenuMusic() {
        guard isMusicEnabled && !allowOwnMusic else { return }

        stopGameMusic()

        menuMusicPlayer = createAudioPlayer(for: menuMusicFile, loops: -1)
        menuMusicPlayer?.volume = 0.4
        menuMusicPlayer?.play()
    }

    func stopMenuMusic() {
        menuMusicPlayer?.stop()
        menuMusicPlayer = nil
    }

    func pauseAllMusic() {
        musicPlayer?.pause()
        menuMusicPlayer?.pause()
    }

    func resumeMusic() {
        guard isMusicEnabled && !allowOwnMusic else { return }
        musicPlayer?.play()
        menuMusicPlayer?.play()
    }

    private func updateMusicState() {
        if isMusicEnabled && !allowOwnMusic {
            resumeMusic()
        } else {
            pauseAllMusic()
        }
    }

    // MARK: - Sound Effects

    func play(_ effect: SoundEffect) {
        guard isSoundEffectsEnabled else { return }

        playSystemSound(for: effect)
    }

    private func playSystemSound(for effect: SoundEffect) {
        let soundID: SystemSoundID

        switch effect {
        case .squareTap:
            soundID = 1104
        case .success:
            soundID = 1057
        case .failure:
            soundID = 1053
        case .gameOver:
            soundID = 1029
        case .combo:
            soundID = 1111
        case .levelUp:
            soundID = 1111
        }

        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Helper Methods

    private func createAudioPlayer(for resource: String, loops: Int) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "mp3") else {
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = loops
            player.prepareToPlay()
            return player
        } catch {
            return nil
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
