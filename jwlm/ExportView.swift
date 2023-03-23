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
    @State private var isSharing: Bool = false
    @State private var exportedURL: URL!
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            Button("Exporter") {
                Task {
                    isExporting = true
                    do {
                        let path = try await jwlmController.exportBackup()
                        isExporting = false
                        exportedURL = NSURL.fileURL(withPath: path)
                        isSharing.toggle()
                    } catch {
                        isExporting = false
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
            if isExporting {
                ProgressView()
            }
        }
        .sheet(isPresented: $showError) {
            ErrorView(error: $errorMessage)
        }
        .sheet(isPresented: $isSharing, content: {
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
