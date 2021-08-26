//
//  PublicationDownloadView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 04.07.21.
//

import SwiftUI

struct PublicationDownloadView: View {
    @AppStorage("downloadPublicationSetting") private var downloadPublicationSetting: DownloadPublication = .ask
    @AppStorage("downloadPublicationCellular") private var downloadPublicationCellular: Bool = false
    @State private var isDownloading: Bool = false

    var body: some View {
        VStack {
            if downloadPublicationSetting == .ask || !downloadPublicationCellular {
                HStack {
                    Text("Preview available")
                    Button("Download", action: {})
                }
            }
            if isDownloading {
                
            }
        }
    }
}

struct PublicationDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        PublicationDownloadView()
    }
}
