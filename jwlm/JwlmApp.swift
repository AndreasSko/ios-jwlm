//
//  jwlmApp.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//

import SwiftUI
import Gomobile

@main
struct JwlmApp: App {
    @StateObject private var jwlmController = JWLMController()
    var body: some Scene {
        WindowGroup {
            ContentView(jwlmController: jwlmController)
        }
    }
}

struct JwlmApp_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        ContentView(jwlmController: jwlmController)
    }
}
