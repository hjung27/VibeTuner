import MicrophonePitchDetector
import SwiftUI
import CoreHaptics
import CoreMotion

struct TunerScreen: View {
    @ObservedObject private var pitchDetector = MicrophonePitchDetector()
    @AppStorage("modifierPreference")
    private var modifierPreference = ModifierPreference.preferSharps
    @AppStorage("selectedTransposition")
    private var selectedTransposition = 0
    lazy var supportsHaptics: Bool = {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()
    var hapticManager: HapticManager = HapticManager()
    
    func performHapticFeedback() {
        hapticManager.restartEngineIfNeeded()
        // Your code to perform specific haptic feedback
        }
    var body: some View {
        //createAndStartHapticEngine()
        TunerView(
            tunerData: TunerData(pitch: pitchDetector.pitch),
            modifierPreference: modifierPreference,
            selectedTransposition: selectedTransposition
        )
        .opacity(pitchDetector.didReceiveAudio ? 1 : 0.5)
        .animation(.easeInOut, value: pitchDetector.didReceiveAudio)
        .task {
            do {
                try await pitchDetector.activate()
            } catch {
                // TODO: Handle error
                print(error)
            }
        }
        .alert(isPresented: $pitchDetector.showMicrophoneAccessAlert) {
            MicrophoneAccessAlert()
        }
//        .task {
//            hapticManager.restartEngineIfNeeded()
//            // TODO: Handle error
//            hapticManager.playHapticFeedback(tuningAccuracy: 8)
//            }
        }
    }

struct TunerScreen_Previews: PreviewProvider {
    static var previews: some View {
        TunerScreen()
    }
}
