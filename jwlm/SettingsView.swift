//
//  SettingsView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 07.12.20.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "needsOnboarding")
                    }, label: {
                        Text("Show Tutorial again")
                    })

                    Link("Open Issue on GitHub",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm/issues/new/choose")!)

                    Link("Review Privacy Policy",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm/wiki/Privacy-Policy")!)
                }

                Section {
                    Link(destination:
                            URL(string: "https://github.com/AndreasSko/ios-jwlm")!,
                         label: {
                            HStack {
                                Image("github")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 25)
                                Text("Visit project on GitHub")
                            }
                    })
                }

            }
            .navigationBarTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
