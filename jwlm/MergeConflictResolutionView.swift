//
//  MergeConflictView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 12.10.20.
//

import SwiftUI
import Gomobile

struct MergeConflictResolutionView: View {
    @ObservedObject var jwlmController: JWLMController
    @Environment(\.presentationMode) var presentationMode
    @Binding private var cancelMerge: Bool
    @State private var conflict: MergeConflict
    @State private var selectedSide: MergeSide?
    @State private var helpOpened = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    init (jwlmController: JWLMController, cancelMerge: Binding<Bool>) {
        self.jwlmController = jwlmController
        self._cancelMerge = cancelMerge
        do {
            try _conflict = State(initialValue: jwlmController.nextConflict())
        } catch {
            _conflict = State(initialValue: MergeConflict(key: "", left: nil, right: nil))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Conflict while merging")
                            + Text(" \(NSLocalizedString(getConflictType(), comment: "Name of the conflict")).").bold()

                        Spacer()

                        Button(action: {
                            helpOpened.toggle()
                        }, label: {
                            Image(systemName: "questionmark.circle")
                        })
                        .sheet(isPresented: $helpOpened) {
                            HelpView(isPresented: $helpOpened,
                                     title: NSLocalizedString("help.conflict.\(getConflictType()).title",
                                                              comment: "Title for specific conflict help text"),
                                     helpText: NSLocalizedString("help.conflict.\(getConflictType()).text",
                                                              comment: "Help text for specific conflict"))
                        }
                    }
                    Text("Which one should be included?")
                }
                .padding()

                MergeConflictOverview(mrt: conflict.left)
                    .padding(.top)

                ScrollView {
                    VStack {
                        MergeConflictDetailsView(conflict: conflict,
                                                 side: .leftSide)
                            .if((selectedSide == MergeSide.leftSide)) { view in
                                view.overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1))
                            }
                            .padding(.top, 40)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            .onTapGesture(count: 1, perform: {
                                selectedSide = .leftSide
                            })

                        MergeConflictDetailsView(conflict: conflict,
                                                 side: .rightSide)
                            .if((selectedSide == MergeSide.rightSide)) { view in
                                view.overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1))
                            }
                            .padding(.horizontal)
                            .onTapGesture(count: 1, perform: {
                                selectedSide = .rightSide
                            })
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: (
                Button(action: {
                    cancelMerge = true
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                })), trailing: (
                Button(action: {
                    do {
                        try jwlmController.mergeConflicts.solveConflict(conflict.key, side: selectedSide?.rawValue)
                        try conflict = jwlmController.nextConflict()
                        selectedSide = nil
                    } catch MergeError.noConflicts {
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        alertMessage = error.localizedDescription
                        showAlert.toggle()
                    }
                }, label: {
                    Text("Continue")
                }).disabled(selectedSide == nil)
                )
            )
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text("Ok")))
        }
    }

    func getConflictType() -> String {
        let left = conflict.left?.model
        switch left {
        case .bookmark:
            return "bookmarks"
        case .userMarkBlockRange:
            return "markings"
        case .note:
            return "notes"
        case .inputField:
            return "input fields"
        default:
            return "error"
        }
    }
}

struct MergeConflictViewResolution_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        MergeConflictResolutionView(jwlmController: jwlmController, cancelMerge: .constant(false))
    }
}
