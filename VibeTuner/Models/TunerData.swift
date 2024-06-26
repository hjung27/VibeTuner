struct TunerData {
    let pitch: Frequency
    let closestNote: ScaleNote.Match
    var hapticManager: HapticManager = HapticManager()
    func identifyClosestString(frequency: Float) -> (distance: Float, closestFrequency: Float) {
        let stringFrequencies = ["E": 82.41, "A": 110.0, "D": 146.83, "G": 196.0, "B": 246.94, "E (High)": 329.63]
        var closest = ("", Double.infinity, Float.infinity)
        
        for (string, freq) in stringFrequencies {
            let distance = abs(Float(freq) - frequency)
            if distance < closest.2 {
                closest = (string, freq, distance)
            }
        }
        print(closest.2)  // Distance
        print(closest.0)  // Note
        return (closest.2, Float(closest.1))  // Returning both distance and closest frequency
    }
}

extension TunerData {
    init(pitch: Double = 445, averagedPitch: Double = 440, averageComputed: Bool = true) {
        self.pitch = Frequency(floatLiteral: pitch)
        self.closestNote = ScaleNote.closestNote(to: self.pitch)
        self.hapticManager.restartEngineIfNeeded()
        
        let averagePitchval = Float(averagedPitch)  // Converting to Float since your identifyClosestString uses Float
        
        if averageComputed {
            let result = self.identifyClosestString(frequency: averagePitchval)
            let tuningAccuracy = result.distance
            let targetFrequency = result.closestFrequency
            let currentFrequency = averagePitchval
            
            // Call playHapticFeedback with all required parameters
            self.hapticManager.playHapticFeedback(tuningAccuracy: tuningAccuracy, currentFrequency: currentFrequency, targetFrequency: targetFrequency)
            self.hapticManager.engineNeedsStart = true
        }
    }
}

    
