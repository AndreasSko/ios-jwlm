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
                        Text("Gérer le catalogue des publications")
                    }

                    NavigationLink(destination: SentrySettingsView(),
                                   tag: "sentry",
                                   selection: $selection) {
                        Text("Partager les rapports d'erreurs")
                    }

                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "needsOnboarding")
                    }, label: {
                        Text("Afficher à nouveau le tutoriel")
                    })

                    #if DEBUG
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "lastCatalogNotification")
                    }, label: {
                        Text("Afficher à nouveau la notification")
                    })
                    #endif
                }

                Section {
                    Link("Puis-je supporter cette application ?",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm"
                                          + "/wiki/Can-I-Support-the-Library-Merger%3F")!)

                    Link("Ouvrir une Issue sur GitHub",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm/issues/new/choose")!)

                    Link("Consulter la politique de confidentialité",
                         destination: URL(string: "https://github.com/AndreasSko/ios-jwlm/wiki/Privacy-Policy")!)

                    Link(destination:
                            URL(string: "https://github.com/AndreasSko/ios-jwlm")!,
                         label: {
                            HStack {
                                Image("github")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 25)
                                Text("Visiter le projet sur GitHub")
                            }
                    })
                }

            }
            .navigationBarTitle("Paramètres")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
