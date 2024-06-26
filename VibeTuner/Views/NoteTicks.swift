import SwiftUI
import CoreHaptics

struct NoteTicks: View {
    let tunerData: TunerData
    let showFrequencyText: Bool

    lazy var supportsHaptics: Bool = {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()
    var hapticManager: HapticManager = HapticManager()
    var body: some View {
        NoteDistanceMarkers()
            .overlay(
                CurrentNoteMarker(
                    frequency: tunerData.pitch,
                    distance: tunerData.closestNote.distance,
                    showFrequencyText: showFrequencyText
                )
            )
            
    
    }
    

}
