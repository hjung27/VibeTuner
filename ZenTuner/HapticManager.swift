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
        var intensity: Float = 0.5
        var sharpness: Float = 0.5
        
        intensity = 1 - (50-abs(tuningAccuracy))/150
        sharpness = 1 - (50-abs(tuningAccuracy))/150
        if tuningAccuracy < 3 {
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(playClickFeedback), userInfo: nil, repeats: false)
            return }
        
        else {intensity = 1 - (50-abs(tuningAccuracy))/150
            sharpness = 1 - (50-abs(tuningAccuracy))/150}
        
        
        let hapticEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
        ], relativeTime: 0, duration: 0.1)
        
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

