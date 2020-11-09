//
//  ContentView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var jwlmController: JWLMController
    
    var body: some View {
        VStack {
            HStack(alignment: .top){
                Text("JW Library Merger")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding()
            VStack() {
                HStack(){
                    BackupView(side: MergeSide.leftSide,
                               jwlmController: jwlmController)
                    Spacer().frame(width: 10.0)
                    BackupView(side: MergeSide.rightSide,
                               jwlmController: jwlmController)
                }
                .padding()
            }
            
            MergeSettingsView(jwlmController: jwlmController)
                .border(Color.gray)
                .padding()
            
            MergeView(jwlmController: jwlmController)
            
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        ContentView(jwlmController: jwlmController)
    }
}
