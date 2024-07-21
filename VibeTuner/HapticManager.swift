import Foundation
import CoreHaptics
import AVFoundation
import MicrophonePitchDetector

enum PitchError {
    case tooLow
    case tooHigh
}

class HapticManager {
    var engine: CHHapticEngine?
    var engineNeedsStart = true
    var feedbackTimer: Timer?
    private var lastFeedbackTime: Date?  // Track the last time feedback was given
    var pitchDetector: MicrophonePitchDetector? // Reference to the pitch detector
    private let minFeedbackInterval: TimeInterval = 2  // Minimum interval between feedbacks in seconds
    
    
    init() {
        createAndStartHapticEngine()
    }
    
    private func createAndStartHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine(audioSession: .sharedInstance())
        } catch {
            fatalError("Failed to create haptic engine: \(error)")
        }
        
        engine?.stoppedHandler = { [weak self] reason in
            //print("Haptic engine stopped for reason: \(reason.rawValue)")
            self?.engineNeedsStart = true
        }
        
        engine?.resetHandler = { [weak self] in
            print("Haptic engine reset")
            self?.engineNeedsStart = true
        }
        
        startEngine()
    }
    

    private func startEngine() {
        guard engineNeedsStart, let engine = engine else { return }
        
        do {
            try engine.start()
            engineNeedsStart = false
        } catch {
            print("Failed to start the haptic engine: \(error)")
        }
    }
    
    func restartEngineIfNeeded() {
        if engineNeedsStart {
            startEngine()
        }
    }
    
    func playHapticFeedback(tuningAccuracy: Float, currentFrequency: Float, targetFrequency: Float) {
        let errorType: PitchError = currentFrequency < targetFrequency ? .tooLow : .tooHigh
        
// Throttle feedback to ensure it is not too frequent
        let now = Date()
        if let lastTime = lastFeedbackTime, now.timeIntervalSince(lastTime) < minFeedbackInterval {
            return
        }
        lastFeedbackTime = now
        
        // Check if the tuning accuracy is below 1
        if tuningAccuracy < 0.25 {
            print (tuningAccuracy)
            triggerHapticFeedbackSuccess(tuningAccuracy:tuningAccuracy)
        } else {
            print (tuningAccuracy)
            triggerHapticFeedback(tuningAccuracy: tuningAccuracy, errorType: errorType)
        }
    }
    
    @objc private func triggerHapticFeedbackSuccess(tuningAccuracy: Float){
        let systemSoundID: SystemSoundID = 1407
        AudioServicesPlaySystemSound(systemSoundID)
        // Pause pitch detection
        pitchDetector?.pauseDetection()
        
        // Can adjust this number. Wait for 3 seconds before resuming pitch detection
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.pitchDetector?.resumeDetection()
        }
    }
    
    func triggerHapticFeedback(tuningAccuracy: Float, errorType: PitchError) {
        let intensity: Float = 1.0  // High intensity for clear feedback
        let sharpness: Float = errorType == .tooHigh ? 0.1 : 1.0  // Less sharp for too high, sharper for too low
        let duration: Double = errorType == .tooHigh ? 1.0 : 0.1  // Longer duration for harsh feedback when too high

        let interval = max(0.001, min(2.0, 0.2052 * Double(tuningAccuracy) - 0.0524))  // Linear function with bounds
        var events = [CHHapticEvent]()
        var currentTime = 0.0
        
        while currentTime < 2 {  // Generate events for 2 seconds duration
            let hapticEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: currentTime, duration: duration)
            
            events.append(hapticEvent)
            currentTime += interval
        }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic feedback: \(error)")
        }
    // Schedule the pause of the pitch detector 0.25 seconds after triggering haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.pitchDetector?.pauseDetection()
        }
        
        // Schedule the resume of the pitch detector 3 seconds after triggering haptic feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.pitchDetector?.resumeDetection()
        }
    }
    
    @objc func playClickFeedback() {
        //guard canPlayClickFeedback else { return }
        
        let hapticEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        ], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play click haptic feedback")
        }
    }
}
@available(iOS 13.0, *)
extension HapticManager {
    private func basicPattern() throws -> CHHapticPattern {
        
        let pattern = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)
        
        return try CHHapticPattern(events: [pattern], parameters: [])
    }
}
    
