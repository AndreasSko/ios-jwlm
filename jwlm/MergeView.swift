//
//  MergeView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 28.10.20.
//

import SwiftUI
import Gomobile

struct MergeView: View {
    @ObservedObject var jwlmController: JWLMController

    var enabled: Bool
    @Binding var doneMerging: Bool

    @State private var isMerging: Bool = false
    @ObservedObject private var mergeProgress: MergeProgress = MergeProgress()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showMergeConflictSheet: Bool = false
    @State private var cancelMerge: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    cancelMerge = false
                    isMerging = true
                    mergeProgress.percent = 1
                    mergeProgress.status = "Merging.."

                    doneMerging = merge()
                    isMerging = false
                    mergeProgress.percent = 0
                }, label: {
                    Text("Merge")
                })
                .disabled(!enabled)
            }
            .font(.title2)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error while merging"),
                      message: Text(self.alertMessage),
                      dismissButton: .default(Text("Ok")))
            }
            .fullScreenCover(isPresented: $showMergeConflictSheet, onDismiss: {
                if cancelMerge {
                    doneMerging = false
                    isMerging = false
                    mergeProgress.percent = 0
                } else {
                    doneMerging = merge(reset: false)
                }
            }, content: {
                MergeConflictResolutionView(jwlmController: jwlmController, cancelMerge: $cancelMerge)
            })

            if mergeProgress.percent > 0 && mergeProgress.percent < 100 {
                ProgressView(mergeProgress.status, value: mergeProgress.percent, total: 100)
                    .padding()
            }

            if doneMerging {
                VStack {
                    Text("🎉").font(.title)
                    ExportView(jwlmController: jwlmController)
                }
            }
        }
    }

    func merge(reset: Bool = true) -> Bool {
        do {
            try jwlmController.merge(reset: reset, progress: mergeProgress)
        } catch MergeError.mergeConflict {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showMergeConflictSheet.toggle()
            }

            return false
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
            return false
        }
        return true
    }
}

struct MergeView_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        MergeView(jwlmController: jwlmController,
                  enabled: true,
                  doneMerging: .constant(false))
    }
}
