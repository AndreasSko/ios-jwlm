//
//  ContentView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var jwlmController: JWLMController

    @State private var sharedUrl: URL?
    @State private var leftSelected: Bool = false
    @State private var rightSelected: Bool = false
    @State private var doneMerging: Bool = false
    @State private var openSettings: Bool = false

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Text("JW Library Merger")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
            VStack {
                HStack {
                    BackupView(side: MergeSide.leftSide,
                               jwlmController: jwlmController,
                               sharedUrl: $sharedUrl,
                               fileSelected: $leftSelected,
                               doneMerging: $doneMerging)
                    BackupView(side: MergeSide.rightSide,
                               jwlmController: jwlmController,
                               sharedUrl: $sharedUrl,
                               fileSelected: $rightSelected,
                               doneMerging: $doneMerging)
                }.padding(.horizontal)
            }

            MergeSettingsView(jwlmController: jwlmController)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
                )
                .shadow(color: Color.gray.opacity(0.2), radius: 20)
                .padding([.top, .horizontal])

            MergeView(jwlmController: jwlmController,
                      enabled: leftSelected && rightSelected,
                      doneMerging: $doneMerging)

            Spacer()

            Button(action: {
                openSettings.toggle()
            }, label: {
                Image(systemName: "gear")
            })
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .sheet(isPresented: $openSettings, content: {
                SettingsView()
            })
        }
        .onOpenURL { url in
            sharedUrl = url
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        ContentView(jwlmController: jwlmController)
    }
}
