import SwiftUI
import CoreMotion
import CoreHaptics
import Combine

struct TunerView: View {
    let tunerData: TunerData
    @State var modifierPreference: ModifierPreference
    @State var selectedTransposition: Int

    private var match: ScaleNote.Match {
        tunerData.closestNote.inTransposition(ScaleNote.allCases[selectedTransposition])
    }

    @AppStorage("HidesTranspositionMenu")
    private var hidesTranspositionMenu = true

    
    var body: some View {
#if os(watchOS)
        ZStack(alignment: Alignment(horizontal: .noteCenter, vertical: .noteTickCenter)) {
            NoteTicks(tunerData: tunerData, showFrequencyText: false)

            MatchedNoteView(
                match: match,
                modifierPreference: modifierPreference
            )
            .focusable()
            .digitalCrownRotation(
                Binding(
                    get: { Float(selectedTransposition) },
                    set: { selectedTransposition = Int($0) }
                ),
                from: 0,
                through: Float(ScaleNote.allCases.count - 1),
                by: 1
            )
        }
#else
        VStack(alignment: .noteCenter) {
            if !hidesTranspositionMenu {
                HStack {
                    TranspositionMenu(selectedTransposition: $selectedTransposition)
                        .padding()

                    Spacer()
                }
            }

            Spacer()

            MatchedNoteView(
                match: match,
                modifierPreference: modifierPreference
            )
//            .task{
//                hapticManager.restartEngineIfNeeded()
//                // TODO: Handle error
//                hapticManager.playHapticFeedback(tuningAccuracy: Float(tunerData.pitch.floatValue))
//                //hapticManager.playPattern()
//                hapticManager.engineNeedsStart=true
//                }
            MatchedNoteFrequency(frequency: tunerData.closestNote.frequency)

            NoteTicks(tunerData: tunerData, showFrequencyText: true)

            Spacer()
        }


#endif
        
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView(
            tunerData: TunerData(),
            modifierPreference: .preferSharps,
            selectedTransposition: 0
        )
    }
}
