struct TunerData {
    let pitch: Frequency
    let closestNote: ScaleNote.Match
    var hapticManager: HapticManager = HapticManager()
    func identifyClosestString() -> Float {
        let stringFrequencies = ["E": 82.41, "A": 110.0, "D": 146.83, "G": 196.0, "B": 246.94, "E (High)": 329.63]
        var closest = ("", Float.infinity)
        
        for (string, freq) in stringFrequencies {
//            let distance = pitch.distance(to: Frequency(floatLiteral: freq))
//            print (distance.cents)
//            if distance.cents < Float(closest.1) {
//                closest = (string, distance.cents)
//            }
            let distance = abs(Float(freq) - Float(pitch.measurement.value))
            if distance < closest.1 {
                closest = (string, distance)
            }
        }
        //print (pitch)
        print (closest.1)
        print (closest.0)
        return closest.1
    }
}

extension TunerData {
    init(pitch: Double = 440) {
        self.pitch = Frequency(floatLiteral: pitch)
        self.closestNote = ScaleNote.closestNote(to: self.pitch)
        self.hapticManager.restartEngineIfNeeded()
                // TODO: Handle error
        let dist=self.identifyClosestString()
        self.hapticManager.playHapticFeedback(tuningAccuracy: dist)
                //hapticManager.playPattern()
        self.hapticManager.engineNeedsStart=true
                }
    }
    
