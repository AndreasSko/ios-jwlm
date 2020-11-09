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
                }) {
                    Text("Cancel")
                }
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
                    }
                    catch {
                        return
                    }
                }) {
                    Text("Continue")
                }
            }.padding([.leading, .trailing])
            
            Divider()
            
            HStack {
                Text("A conflict has happened while merging.")
                Spacer()
            }.padding()
            
            Spacer()
            
            HStack {
                MergeConflictView(conflict: getConflict(), side: .leftSide)
                    .if((selectedSide == MergeSide.leftSide)) { view in
                        view.border(Color.blue)
                    }
                    .padding()
                    .onTapGesture(count: 1, perform: {
                        selectedSide = .leftSide
                    })
                
                MergeConflictView(conflict: getConflict(), side: .rightSide)
                    .if((selectedSide == MergeSide.rightSide)) { view in
                        view.border(Color.blue)
                    }
                    .padding()
                    .onTapGesture(count: 1, perform: {
                        selectedSide = .rightSide
                    })
            }
                        
            Spacer()
        }
    }
    
    func getConflict() -> Gomobile.GomobileMergeConflict {
        var conflict: Gomobile.GomobileMergeConflict
        do {
            try conflict = jwlmController.mergeConflicts.getConflict(conflictIndex)
        } catch {
            return Gomobile.GomobileMergeConflict()
        }
        
        return conflict
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
        }
        else {
            self
        }
    }
}
