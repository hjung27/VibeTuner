import AVFoundation
import SwiftUI
#if os(watchOS)
import WatchKit
#endif

public final class MicrophonePitchDetector: ObservableObject {
    private let engine = AudioEngine()
    private var isRunning = false
    private var tracker: PitchTap!

    @Published public var pitch: Double = 440
    @Published public var averagedPitch: Double=0.0
    @Published public var didReceiveAudio = false
    @Published public var showMicrophoneAccessAlert = false
    @Published public var pitches: [Double] = []
    @Published public var averageComputed=false
    public init() {}

    @MainActor
    public func activate() async throws {
        guard !isRunning else { return }

        switch await MicrophoneAccess.getOrRequestPermission() {
        case .granted:
            try await setUpPitchTracking()
        case .denied:
            showMicrophoneAccessAlert = true
        }
    }

    private func setUpPitchTracking() async throws {
#if !os(macOS)
        try engine.configureSession()
#endif
        tracker = PitchTap(engine.inputMixer, handler: { pitch in
            Task { @MainActor in
                self.pitch = pitch
                self.pitches.append(pitch)
                if (self.pitches.count == 2) {
                    self.averageComputed=true
                    self.averagedPitch = self.pitches.reduce(0, +) / Double(self.pitches.count)
                    self.pitches.removeAll() // Optionally, you can keep only the last 20
                }
            }
        }, didReceiveAudio: {
            Task { @MainActor in
                self.didReceiveAudio = true
                self.averageComputed=false
            }
        })

        isRunning = true
        try engine.start()
        tracker.start()
    }
}
