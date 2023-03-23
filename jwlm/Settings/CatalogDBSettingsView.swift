//
//  CatalogDBSettingsView.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 13.12.20.
//

import SwiftUI
import Gomobile

struct CatalogDBSettingsView: View {
    @State private var isDownloading: Bool = false
    @State private var downloadError: String = ""
    @State private var catalogExists: Bool = GomobileCatalogExists(catalogDBPath?.path)
    @State private var catalogNeedsUpdate: Bool = GomobileCatalogNeedsUpdate(catalogDBPath?.path)
    @State private var downloadProgress: Float = 0
    @State private var downloadManager: GomobileDownloadManager?

    var body: some View {
        VStack(alignment: .leading) {
            Text("settings.catalogDB.quickInfo")
                .padding(.bottom)

            VStack(alignment: .leading) {
                VStack(alignment: .custom) {
                    HStack {
                        Text("Status:").bold()
                        if catalogExists {
                            if catalogNeedsUpdate {
                                Text("Dépassé")
                                    .alignmentGuide(.custom) { $0[.leading] }
                            } else {
                                Text("À jour")
                                    .alignmentGuide(.custom) { $0[.leading] }
                            }

                            Spacer()

                            Button(action: {
                                downloadCatalog()
                            }, label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }).disabled(isDownloading)

                            Button(action: {
                                deleteCatalog()
                            }, label: {
                                Image(systemName: "trash")
                            }).disabled(isDownloading).padding(.bottom, 2)

                        } else {
                            if isDownloading {
                                Text("Téléchargement...")
                                    .alignmentGuide(.custom) { $0[.leading] }
                            } else {
                                Text("Non téléchargé")
                                    .alignmentGuide(.custom) { $0[.leading] }
                            }

                            Spacer()

                            Button(action: {
                                downloadCatalog()
                            }, label: {
                                Image(systemName: "arrow.down.to.line")
                            }).disabled(isDownloading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if catalogExists {
                        HStack {
                            Text("Taille :").bold()

                            let fileSize = ByteCountFormatter
                                .string(fromByteCount: GomobileCatalogSize(catalogDBPath?.path),
                                        countStyle: .file)
                            Text(fileSize).alignmentGuide(.custom) { $0[.leading] }
                        }
                    }
                }

                if isDownloading {
                    HStack {
                        ProgressView(value: downloadProgress).animation(.easeIn)
                        Button(action: {
                            cancelDownload()
                        }, label: {
                            Image(systemName: "xmark").accentColor(.red)
                        })
                    }.padding(.vertical)
                }

                if downloadError != "" {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        DisclosureGroup("Une erreur est survenue") {
                            Text(downloadError)
                        }
                    }
                    .padding(.top, 5)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.1), lineWidth: 1)
            )
            .shadow(color: Color.gray.opacity(0.2), radius: 20)

            Text("settings.catalogDB.downloadSize").padding(.top, 5)

            Spacer()

            DisclosureGroup("Qu'est-ce qu'un catalogue de publication ?") {
                Text("settings.catalogDB.explainer")
            }

            DisclosureGroup("Attention") {
                Text("settings.catalogDB.disclaimer")
                Link("Politique de confidentialité disponible sur jw.org", destination: URL(string: "https://www.jw.org/en/privacy-policy/")!)
            }

        }
        .padding()
        .navigationBarTitle("Catalogue de publication")
        .navigationBarTitleDisplayMode(.inline)
    }

    func downloadCatalog() {
        downloadError = ""
        downloadManager = GomobileDownloadCatalog(catalogDBPath?.path)
        if downloadManager == nil {
            return
        }

        isDownloading = true
        DispatchQueue.global().async {
            while !(downloadManager!.progress?.done ?? false) {
                downloadProgress = Float(downloadManager!.progress?.progress ?? 0)
                usleep(2500)
            }

            isDownloading = false
            if downloadManager?.downloadSuccessful() ?? false {
                catalogExists = GomobileCatalogExists(catalogDBPath?.path)
                catalogNeedsUpdate = GomobileCatalogNeedsUpdate(catalogDBPath?.path)
            } else if !(downloadManager?.progress?.canceled ?? false) {
                downloadError = downloadManager?.error() ?? "Erreur pendant le téléchargement"
            }
        }
    }

    func cancelDownload() {
        downloadManager?.cancelDownload()
        isDownloading = false
    }

    func deleteCatalog() {
        do {
            try FileManager.default.removeItem(at: catalogDBPath!)
        } catch {
            print("Pas de catalog.db a supprimer")
        }
        catalogExists = GomobileCatalogExists(catalogDBPath?.path)
    }
}

struct CatalogDBSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CatalogDBSettingsView()
    }
}
