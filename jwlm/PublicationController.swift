//
//  PublicationController.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 13.12.20.
//

import Foundation
import Gomobile

let catalogDBPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                    .appendingPathComponent("catalog.db")
let publicationDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?
                    .appendingPathComponent("publications")

struct Publication: Codable {
    let id: Int
    let publicationRootKeyId: Int
    let mepsLanguageId: Int
    let publicationTypeId: Int
    let issueTagNumber: Int
    let title: String
    let issueTitle: String
    let shortTitle: String
    let coverTitle: String
    let undatedTitle: String
    let undatedReferenceTitle: String
    let year: Int
    let symbol: String
    let keySymbol: String
    let reserved: Int
}

func generatePublLookup(_ location: Location?) -> GomobilePublicationLookup {
    let publQuery = GomobilePublicationLookup()

    publQuery.documentID = location?.documentId.int32 ?? 0
    publQuery.keySymbol = location?.keySymbol.string ?? ""
    publQuery.issueTagNumber = location?.issueTagNumber ?? 0
    publQuery.mepsLanguage = location?.mepsLanguage ?? 0

    return publQuery
}

func lookupPublicationFor(_ location: Location?) -> Publication? {
    let query = generatePublLookup(location)
    return lookupPublication(query)
}

func lookupPublication(_ query: GomobilePublicationLookup) -> Publication? {
    if !GomobileCatalogExists(catalogDBPath?.path) {
        return nil
    }

    let result = GomobileLookupPublication(catalogDBPath?.path, query)
    do {
        return try JSONDecoder().decode(Publication.self,
                                 from: result.data(using: .utf8)!)
    } catch {
        return nil
    }
}

func publicationDownloaded(_ publication: Publication) -> Bool {
    return getPublicationPath(publication) != ""
}

func getPublicationPath(_ publication: Publication) -> String {
    var jsonString: String
    do {
        let jsonData = try JSONEncoder().encode(publication)
        jsonString = String(data: jsonData, encoding: .utf8) ?? ""
    } catch {
        return ""
    }
    return Gomobile.GomobileGetPublicationPath(jsonString, publicationDir?.absoluteString)
}
