////
////  Haptics.swift
////  ZenTuner
////
////  Created by Hoyoung Jung on 2024-05-26.
////
//
//import Foundation
//import CoreHaptics
//var hapticEngine: CHHapticEngine?
//do {
//    hapticEngine = try CHHapticEngine()
//    try hapticEngine?.start()
//} catch {
//    print("There was an error creating the haptic engine: \(error)")
//}
//
//func playHapticFeedback(tuningAccuracy: Float) {
//    var intensity: Float = 0.5
//    var sharpness: Float = 0.5
//
//    switch tuningAccuracy {
//    case ...-10, 10...:
//        intensity = 0.4
//        sharpness = 0.4
//    case ...-5, 5...:
//        intensity = 1.0
//        sharpness = 1.0
//    case -5...5:
//        return playClickFeedback()
//    default:
//        break
//    }
//
//    let hapticEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [
//        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
//        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
//    ], relativeTime: 0, duration: 0.1)
//    
//    do {
//        let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
//        let player = try hapticEngine?.makePlayer(with: pattern)
//        try player?.start(atTime: 0)
//    } catch {
//        print("Failed to play custom haptic feedback: \(error)")
//    }
//}
//
//func playClickFeedback() {
//    let hapticEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
//        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
//        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
//    ], relativeTime: 0)
//    
//    do {
//        let pattern = try CHHapticPattern(events: [hapticEvent], parameters: [])
//        let player = try hapticEngine?.makePlayer(with: pattern)
//        try player?.start(atTime: 0)
//    } catch {
//        print("Failed to play click haptic feedback: \(toError)")
//    }
//}
//
