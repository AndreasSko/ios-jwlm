//
//  ExportView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 12.10.20.
//

import SwiftUI

struct ExportView: View {
    @ObservedObject var jwlmController: JWLMController

    @State private var isExporting: Bool = false
    @State private var exportedURL: URL!
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Button("Export") {
                do {
                    let path = try jwlmController.exportBackup()
                    exportedURL = NSURL.fileURL(withPath: path)
                    isExporting.toggle()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
        .sheet(isPresented: $showError) {
            ErrorView(error: $errorMessage)
        }
        .sheet(isPresented: $isExporting, content: {
            ShareView(url: self.$exportedURL)
        })
    }
}

struct ShareView: UIViewControllerRepresentable {
    @Binding var url: URL!

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url!],
                                        applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ShareView>) {

    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        let jwlmController = JWLMController()
        ExportView(jwlmController: jwlmController)
    }
}
