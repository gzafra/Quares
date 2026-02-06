import AVFoundation
import Combine

/// Manages all game audio including background music and sound effects
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
    private var effectPlayers: [SoundEffect: AVAudioPlayer] = [:]
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
        case levelUp = "level_up"
    }

    // MARK: - Initialization
    private init() {
        self.isMusicEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.musicEnabled, defaultValue: true)
        self.isSoundEffectsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.soundEffectsEnabled, defaultValue: true)
        self.allowOwnMusic = UserDefaults.standard.bool(forKey: UserDefaultsKeys.allowOwnMusic, defaultValue: false)

        configureAudioSession()
        setupNotifications()
    }

    // MARK: - Audio Session Configuration
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()

            if allowOwnMusic {
                // Allow user's music to mix with game sounds
                try session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            } else {
                // Game takes over audio
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

        // Randomly select game music
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

        // Use system sounds as placeholders
        playSystemSound(for: effect)
    }

    private func playSystemSound(for effect: SoundEffect) {
        // Map effects to system sound IDs
        let soundID: SystemSoundID

        switch effect {
        case .squareTap:
            soundID = 1104 // Tock sound
        case .success:
            soundID = 1057 // Success/achievement sound
        case .failure:
            soundID = 1053 // Error sound
        case .gameOver:
            soundID = 1029 // Arcade game over sound
        case .levelUp:
            soundID = 1111 // Power up sound
        }

        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Helper Methods
    private func createAudioPlayer(for resource: String, loops: Int) -> AVAudioPlayer? {
        // For now, return nil since we don't have actual audio files
        // In a real implementation, this would load from the bundle
        // Return a placeholder player that does nothing
        return nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UserDefaults Helper
private extension UserDefaults {
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        if object(forKey: key) == nil {
            return defaultValue
        }
        return bool(forKey: key)
    }
}

// MARK: - AudioServices System Sound IDs
// These are the system sound IDs available on iOS
// 1104 - Tock
// 1057 - Success/Achievement
// 1053 - Error
// 1029 - Arcade Game Over
// 1111 - Power Up
import AudioToolbox
