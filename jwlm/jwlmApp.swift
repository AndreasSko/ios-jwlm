//
//  jwlmApp.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//

import SwiftUI
import Gomobile
import Sentry

@main
struct JwlmApp: App {
    @StateObject private var jwlmController = JWLMController()
    @AppStorage("needsOnboarding") private var needsOnboarding: Bool = true
    @AppStorage("enableSentry") private var enableSentry: Bool = false

    var body: some Scene {
        WindowGroup {
            if needsOnboarding {
                OnboardingView(needsOnboarding: $needsOnboarding)
            } else {
                ContentView(jwlmController: jwlmController)
            }
        }
    }

    init() {
        setupSentry(enableSentry: enableSentry)
    }

}

struct JwlmApp_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        ContentView(jwlmController: jwlmController)
    }
}

func setupSentry(enableSentry: Bool) {
    SentrySDK.start { options in
        options.enabled = enableSentry
        options.dsn = "https://e46082df0a5343d0bfe1615b169834ff@o1083063.ingest.sentry.io/4504147949780992"
        options.enableAutoSessionTracking = false
        options.enableNetworkTracking = false

        #if DEBUG
        options.beforeSend = { event in
            print("Sending: \(event)")
            return event
        }
        #endif
    }
}
