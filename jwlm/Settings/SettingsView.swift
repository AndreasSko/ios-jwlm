//
//  SettingsView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 07.12.20.
//

import SwiftUI

struct SettingsView: View {
    @State var selection: String?

    init() {}
    init(selection: String) {
        self._selection = State(initialValue: selection)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    NavigationLink(destination: CatalogDBSettingsView(),
                                   tag: "catalog",
                                   selection: $selection) {
                        Text("Manage Publication Catalog")
                    }

                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "needsOnboarding")
                    }, label: {
                        Text("Show Tutorial again")
                    })

                    #if DEBUG
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "lastCatalogNotification")
                    }, label: {
                        Text("Show Notification again")
                    })
                    #endif
                }

                Section {
                    Link("Open Issue on GitHub",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm/issues/new/choose")!)

                    Link("Review Privacy Policy",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm/wiki/Privacy-Policy")!)

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
