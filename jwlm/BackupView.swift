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
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
                    .font(.title)
                    .padding()
                Text("Select Backup")
                    .foregroundColor(.black)
            } else {
                VStack(alignment: .leading) {
                    Text("BlockRanges: " + String(dbStats.blockRange))
                    Text("Bookmarks: " + String(dbStats.bookmark))
                    Text("Locations: " + String(dbStats.location))
                    Text("Notes: " + String(dbStats.note))
                    Text("Tags: " + String(dbStats.tag))
                    Text("TagMaps: " + String(dbStats.tagMap))
                    Text("UserMarks: " + String(dbStats.userMark))
                }
                .padding()

                Image(systemName: "checkmark.circle")
                .font(.title)
                .foregroundColor(.green)
                    .padding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 250)
        .background(Rectangle().fill(Color.gray.opacity(0.2)).shadow(radius: 10, x: 10, y: 10))
        .cornerRadius(5)
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
