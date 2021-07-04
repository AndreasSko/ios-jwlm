//
//  MarkingPreviewSettingsView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 04.07.21.
//

import SwiftUI

struct MarkingPreviewSettingsView: View {
    @AppStorage("downloadPublicationSetting") private var downloadPublicationSetting: DownloadPublication = .disabled
    @AppStorage("downloadPublicationCellular") private var downloadPublicationCellular: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("It is possible to show a preview of markings in order to get a better understanding of the conflict. For that to work, JWLM needs to download the publication first.")
            Picker(selection: $downloadPublicationSetting, label: Text("Download publication of not present")) {
                Text("Always").tag(DownloadPublication .always)
                Text("Ask").tag(DownloadPublication .ask)
                Text("Disable").tag(DownloadPublication .disabled)
            }
            .pickerStyle(SegmentedPickerStyle())
            Toggle(isOn: $downloadPublicationCellular) {
                Text("Download over Cellular")
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Marking Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MarkingPreviewSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MarkingPreviewSettingsView()
    }
}

enum DownloadPublication: String {
    case always = "Always"
    case ask = "Ask"
    case disabled = "Disabled"
}
