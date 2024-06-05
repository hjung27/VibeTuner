//
//  HapticManager.swift
//  ZenTuner
//
//  Created by Hoyoung Jung on 2024-05-26.
//

import Foundation
import CoreHaptics
import AVFoundation

class HapticManager {
    var engine: CHHapticEngine?
    var engineNeedsStart = true
    private var lastFeedbackTime: Date?  // Track the last time feedback was given
    
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
    //from stackexchange
    func playPattern() {
        do {
            let pattern = try continuousVibration()
            startEngine()
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
            engine?.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Failed to play pattern: \(error)")
        }
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
    func playHapticFeedback(tuningAccuracy: Float) {
        // Check if the tuning accuracy is below 1
        if tuningAccuracy < 0.75 {
            // Schedule haptic feedback to play after a delay (e.g., 2 seconds)
            print (tuningAccuracy)
            DispatchQueue.main.async {
                Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.triggerHapticFeedbackSuccess), userInfo: NSNumber(value: tuningAccuracy), repeats: false)
            }
        } else {
            // Trigger haptic feedback immediately if tuning accuracy is 1 or above
            triggerHapticFeedback(tuningAccuracy: tuningAccuracy)
        }
    }
    @objc private func triggerHapticFeedbackSuccess(tuningAccuracy: Float){
        let systemSoundID: SystemSoundID = 1008
        AudioServicesPlaySystemSound(systemSoundID)
    }

    private func triggerHapticFeedback(tuningAccuracy: Float) {
        var intensity: Float = 0.5
        var sharpness: Float = 0.5
        
        // Set intensity and sharpness based on your logic
        intensity = 1
        sharpness = 1
        
        //        if tuningAccuracy < 3 {
        //            let systemSoundID: SystemSoundID = 1008
        //            AudioServicesPlaySystemSound(systemSoundID)
        //        } else {
        //            intensity = 1
        //            sharpness = 1
        //        }
        var dur = 0.25
        if (tuningAccuracy < 3) {
            dur = 5
        }
        else if (tuningAccuracy < 10) {
            dur = 4
        }
        else if (tuningAccuracy < 15) {
            dur = 2
        }
        else if (tuningAccuracy < 20) {
            dur = 1
        }
        else if (tuningAccuracy < 200) {
            dur = 0.5
        }
        let hapticEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        ], relativeTime: 0, duration: Double(dur))

        do {
            let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play custom haptic feedback: \(error)")
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
        //do {sleep(2)}
        // Play the click feedback
        // Ensure your engine and pattern setup code goes here
        
        // Disable further feedback until the cooldown period has passed
//        canPlayClickFeedback = false
//        feedbackCooldownTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
//            self?.canPlayClickFeedback = true
//        }
    }
}

@available(iOS 13.0, *)
extension HapticManager {
  private func basicPattern() throws -> CHHapticPattern {

        let pattern = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 3.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 3.0)
          ],
          relativeTime: 1)

        return try CHHapticPattern(events: [pattern], parameters: [])
  }
    
    private func continuousVibration() throws -> CHHapticPattern {
        let duration = 1000 // ms suppose
        let hapticIntensity: Float
        hapticIntensity = 1.0
        let continuousVibrationEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: hapticIntensity)
            ],
            relativeTime: 0,
            duration: (Double(duration)/1000))
        return try CHHapticPattern(events: [continuousVibrationEvent], parameters: [])
    }
}

