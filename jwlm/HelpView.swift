//
//  HelpPopupView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 13.11.20.
//

import SwiftUI

struct HelpView: View {
    @Binding var isPresented: Bool
    var title: String?
    var helpText: String?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Button("Done") {
                    isPresented.toggle()
                }
            }
            .padding(.horizontal)
            .padding(.top)

            Divider()

            VStack(alignment: .leading) {
                Text(title ?? "").font(.title3).padding(.bottom)
                Text(helpText ?? "")
            }
            .padding()

            Spacer()
        }

    }
}

struct HelpPopupView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(
            isPresented: .constant(true),
            title: "A title",
            helpText: "This is a help text..")
    }
}
