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
    @State private var conflictIndex: Int!
    @State private var selectedSide: MergeSide?

    init (jwlmController: JWLMController, cancelMerge: Binding<Bool>) {
        self.jwlmController = jwlmController
        self._cancelMerge = cancelMerge
        _conflictIndex = State(initialValue: jwlmController.nextConflictID())
    }

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Button(action: {
                    cancelMerge = true
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                })
                Spacer()
                Button(action: {
                    do {
                        try jwlmController.mergeConflicts.solveConflict(conflictIndex, side: selectedSide?.rawValue)
                        if jwlmController.nextConflictID() >= 0 {
                            conflictIndex = jwlmController.nextConflictID()
                            selectedSide = nil
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    } catch {
                        return
                    }
                }, label: {
                    Text("Continue")
                })
            }.padding([.leading, .trailing])

            Divider()

            HStack {
                let left = jwlmController.getConflict(index: conflictIndex).left?.model
                switch left {
                case .bookmark:
                    Text("A conflict happened while merging") + Text(" bookmarks.").bold()
                case .note:
                    Text("A conflict happened while merging") + Text(" notes.").bold()
                case .userMarkBlockRange:
                    Text("A conflict happened while merging") + Text(" markings.").bold()
                default:
                    Text("A conflict has happened while merging.")
                }
            }.padding()

            MergeConflictOverview(mrt: jwlmController.getConflict(index: conflictIndex).left).padding()

            ScrollView {
                VStack {
                    MergeConflictDetailsView(conflict: jwlmController.getConflict(index: conflictIndex),
                                             side: .leftSide)
                        .if((selectedSide == MergeSide.leftSide)) { view in
                            view.overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1))
                        }
                        .padding()
                        .onTapGesture(count: 1, perform: {
                            selectedSide = .leftSide
                        })

                    MergeConflictDetailsView(conflict: jwlmController.getConflict(index: conflictIndex),
                                             side: .rightSide)
                        .if((selectedSide == MergeSide.rightSide)) { view in
                            view.overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1))
                        }
                        .padding()
                        .onTapGesture(count: 1, perform: {
                            selectedSide = .rightSide
                        })
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
        }
    }
}

struct MergeConflictViewResolution_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        MergeConflictResolutionView(jwlmController: jwlmController, cancelMerge: .constant(false))
    }
}

// https://blog.kaltoun.cz/conditionally-applying-view-modifiers-in-swiftui/
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}
