//
//  JWLBackupView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//  Copyright © 2020 Andreas Skorczyk. All rights reserved.
//

import SwiftUI
import Gomobile

struct BackupView: View {
    var side: MergeSide
    @ObservedObject var jwlmController: JWLMController

    @State private var fileSelected: Bool = false
    @State private var isImporting: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var dbStats: GomobileDatabaseStats = GomobileDatabaseStats()

    var body: some View {
        VStack {
            if !fileSelected {
                Button(action: {
                    isImporting.toggle()
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                })
                    .font(.title)
                    .padding()
                Text("Select Backup")
                    .foregroundColor(.black)
            } else {
                VStack(alignment: .custom) {

                    HStack {
                        Text("Bookmarks:").bold()
                        Text(String(dbStats.bookmark))
                            .alignmentGuide(.custom) { $0[.leading] }
                    }

                    HStack {
                        Text("Notes:").bold()
                        Text(String(dbStats.note))
                            .alignmentGuide(.custom) { $0[.leading] }
                    }

                    HStack {
                        Text("Tags:").bold()
                        Text(String(dbStats.tag))
                            .alignmentGuide(.custom) { $0[.leading] }
                    }

                    HStack {
                        Text("Taggings:").bold()
                        Text(String(dbStats.tagMap))
                            .alignmentGuide(.custom) { $0[.leading] }
                    }

                    HStack {
                        Text("Markings:").bold()
                        Text(String(dbStats.userMark))
                            .alignmentGuide(.custom) { $0[.leading] }
                    }
                }
                .padding()

                Image(systemName: "checkmark.circle")
                .font(.title)
                .foregroundColor(.green)
                    .padding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
        )
        .shadow(color: Color.gray.opacity(0.2), radius: 20)
        .contentShape(Rectangle())
        .onTapGesture {
            isImporting.toggle()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error while importing backup"),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text("Ok")))
        }
        .fileImporter(isPresented: $isImporting,
                      allowedContentTypes: [.jwlibrary]) { (result) in
            do {
                let url = try result.get()
                try jwlmController.importBackup(url: url, side: side)
                fileSelected = true
                dbStats = jwlmController.dbWrapper.stats(side.rawValue)!
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }

    }
}

struct JWLBackupView_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        BackupView(side: MergeSide.leftSide, jwlmController: jwlmController)
    }
}
