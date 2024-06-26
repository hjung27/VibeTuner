import SwiftUI
import CoreHaptics
import CoreMotion

import Combine

@main
struct ZenTunerApp: App {
    

    var body: some Scene {
        WindowGroup {
            TunerScreen()
                .onAppear {
                    #if os(iOS)
                        UIApplication.shared.isIdleTimerDisabled = true
                    #endif
                }
        }
    }
}
