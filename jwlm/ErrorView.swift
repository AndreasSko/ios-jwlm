//
//  ErrorView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 30.12.21.
//

import SwiftUI

struct ErrorView: View {
    @Binding var error: String

    @AppStorage("enableSentry") private var enableSentry: Bool = false

    @State private var errorCopied: Bool = false
    @State private var openSentrySettings: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("😕 Quelque chose s'est mal passé")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                Spacer()
            }.padding(.bottom, 5)

            Text("errorView.reportError")
                .padding(.bottom)

            Text("L'erreur suivante a été renvoyée :")
                .bold()
                .padding(.bottom, 1)

            Text(error)
                .font(.system(.body, design: .monospaced))
                .onTapGesture {
                    copyError()
                }
            HStack {
                Spacer()
                Button(errorCopied ? "Copié" : "Copie") {
                    copyError()
                }
                .foregroundColor(Color.white)
                .padding(8)
                .background(Color.blue)
                .clipShape(Capsule())
            }
            Spacer()
            Text("errorView.sentryHint")
            HStack {
                Toggle(isOn: $enableSentry) {
                    Text("Partager des rapports d'erreurs et des statistiques")
                }
                .onChange(of: enableSentry) { _ in
                    setupSentry(enableSentry: enableSentry)
                }
            }
            Button {
                openSentrySettings.toggle()
            } label: {
                Text("En savoir plus")
            }

        }
        .padding()
        .sheet(isPresented: $openSentrySettings, content: {
            SettingsView(selection: "sentry")
        })
    }

    func copyError() {
        UIPasteboard.general.string = error
        errorCopied = true
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next line_length
        ErrorView(error: .constant("Erreur lors de l'analyse des résultats de la base de données SQLite : sql : erreur d'analyse sur l'index de colonne 4, nom \"Tagld\": la conversion de NULL en int n'est pas prise en charge"))
    }
}
