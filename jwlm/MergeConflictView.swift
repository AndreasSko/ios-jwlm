//
//  MergeConflictView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 28.10.20.
//

import SwiftUI
import Gomobile

struct MergeConflictView: View {
    var conflict: Gomobile.GomobileMergeConflict
    var side: MergeSide

    var body: some View {
        VStack {
            Text(selectConflict())
                .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 250)
        .background(Rectangle().fill(Color.gray.opacity(0.2)).shadow(radius: 10, x: 10, y: 10))
        .cornerRadius(5)
    }

    func selectConflict() -> String {
        if side == .leftSide {
            return conflict.left
        }
        return conflict.right
    }
}

struct MergeConflictView_Previews: PreviewProvider {
    static var previews: some View {
        let conflict = Gomobile.GomobileMergeConflict()
        MergeConflictView(conflict: conflict, side: .leftSide)
    }
}
