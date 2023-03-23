//
//  JwlmController.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//  Copyright © 2020 Andreas Skorczyk. All rights reserved.
//

import Foundation
import Gomobile
import Sentry

enum MergeSide: String {
    case leftSide
    case rightSide
}

struct ModelRelatedTuple: Decodable {
    let model: Model
    let related: Related
}

struct MergeConflict {
    let key: String
    let left: ModelRelatedTuple?
    let right: ModelRelatedTuple?
}

enum ConflictSolver: String {
    case disabled = ""
    case chooseLeft = "chooseLeft"
    case chooseRight = "chooseRight"
    case chooseNewest = "chooseNewest"
}

struct MergeSettings {
    var bookmarkResolver: ConflictSolver
    var markingResolver: ConflictSolver
    var noteResolver: ConflictSolver
    var inputFieldResolver: ConflictSolver
}

class MergeProgress: ObservableObject {
    @Published var status: String = ""
    @Published var percent: Float = 0

    @MainActor
    func update(status: String, percent: Float) {
        self.status = status
        self.percent = percent
    }
}

enum GeneralError: Error {
    case general(message: String)
    case timeout(message: String)
}

extension GeneralError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .timeout(let message), .general(let message):
            return message
        }
    }
}

enum MergeError: Error {
    case notInitialized(message: String)
    case mergeConflict
    case noConflicts
    case error(message: String)
}

extension MergeError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notInitialized(let message):
            return message
        case .error(let message):
            return message
        default:
            return ""
        }
    }
}

class JWLMController: ObservableObject {
    var dbWrapper: GomobileDatabaseWrapper
    var mergeConflicts: GomobileMergeConflictsWrapper
    var settings: MergeSettings

    private var solvedConflicts = 0

    init() {
        self.dbWrapper = GomobileDatabaseWrapper()
        self.mergeConflicts = GomobileMergeConflictsWrapper()
        self.mergeConflicts.initDBWrapper(dbWrapper)
        self.settings = MergeSettings(bookmarkResolver: .disabled,
                                      markingResolver: .disabled,
                                      noteResolver: .disabled,
                                      inputFieldResolver: .disabled)
    }

    func importBackup(url: URL, side: MergeSide) async throws {
        do {
            _ = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }

            try downloadFileIfNecessary(url: url)

            try dbWrapper.importJWLBackup(url.path, side: side.rawValue)
            url.stopAccessingSecurityScopedResource()
            cleanUpInbox()
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }
    }

    func downloadFileIfNecessary(url: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            return
        }

        try fileManager.startDownloadingUbiquitousItem(at: url)

        var wait = 0
        while true {
            if wait > 60 {
                throw GeneralError.timeout(message: "Echec du téléchargement \(url.lastPathComponent). "
                                           + "Timeout après \(wait) secondes.")
            }
            if fileManager.fileExists(atPath: url.path) {
                return
            }
            sleep(1)
            wait += 1
        }
    }

    func exportBackup() async throws -> String {
        do {
            cleanUpMergedFiles()
            if !self.dbWrapper.dbIsLoaded("mergeSide") {
                throw MergeError.notInitialized(message: "Il n'y a pas encore de sauvegarde fusionnée")
            }

            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let filename = "Fusionné" + String(Int(NSDate().timeIntervalSince1970)) + ".jwlibrary"
            let path = dir?.appendingPathComponent(filename).path

            try dbWrapper.exportMerged(path)

            return path!
        } catch {
            SentrySDK.capture(error: error)
            throw error
        }
    }

    // cleanUpMergedFiles removes all files starting with `merged` from the documentDirectory,
    // as they are the result of older merges
    func cleanUpMergedFiles() {
        let fm = FileManager.default
        do {
            let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first
            let files = try fm.contentsOfDirectory(at: dir!.absoluteURL,
                                                   includingPropertiesForKeys: [.isRegularFileKey])
            for file in files where file.lastPathComponent.hasPrefix("Fusionné") {
                try fm.removeItem(at: file)
                print("Nettoyer \(file.absoluteString)")
            }
        } catch {
            SentrySDK.capture(error: error)
            print("Erreur lors de la tentative de nettoyage des anciens fichiers")
        }
    }

    // cleanUpInbox removes all files inside the inbox
    func cleanUpInbox() {
        let fm = FileManager.default
        do {
            let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Boîte de réception")
            let files = try fm.contentsOfDirectory(at: dir!.absoluteURL,
                                                   includingPropertiesForKeys: [.isRegularFileKey])
            for file in files {
                try fm.removeItem(at: file)
                print("Nettoyer \(file.absoluteString)")
            }
        } catch {
            SentrySDK.capture(error: error)
            print("Erreur lors de la tentative de nettoyage de la boîte de réception")
        }
    }

    func merge(reset: Bool = true, progress: MergeProgress) async throws {
        if !self.dbWrapper.dbIsLoaded(MergeSide.leftSide.rawValue)
           || !self.dbWrapper.dbIsLoaded(MergeSide.rightSide.rawValue) {
            throw MergeError.notInitialized(message: "Au moins une sauvegarde n'a pas encore été importée")
        }
        if reset {
            mergeConflicts = GomobileMergeConflictsWrapper()
            mergeConflicts.initDBWrapper(dbWrapper)
        }

        dbWrapper.init_()

        do {
            await progress.update(status: "Fusionner les emplacements", percent: 14)
            try dbWrapper.mergeLocations()

            await progress.update(status: "Fusionner les signets", percent: 28)
            try dbWrapper.mergeBookmarks(self.settings.bookmarkResolver.rawValue, mcw: self.mergeConflicts)

            await progress.update(status: "Fusionner les champs de saisie", percent: 42)
            try dbWrapper.mergeInputFields(self.settings.inputFieldResolver.rawValue, mcw: self.mergeConflicts)

            await progress.update(status: "Fusionner les balises", percent: 56)
            try dbWrapper.mergeTags()

            await progress.update(status: "Fusionner les soulignements", percent: 70)
            try dbWrapper.mergeUserMarkAndBlockRange(self.settings.markingResolver.rawValue, mcw: self.mergeConflicts)

            await progress.update(status: "Fusionner les notes", percent: 84)
            try dbWrapper.mergeNotes(self.settings.noteResolver.rawValue, mcw: self.mergeConflicts)

            await progress.update(status: "Fusion de TagMaps", percent: 98)
            try dbWrapper.mergeTagMaps()

            await progress.update(status: "Fait", percent: 100)
        } catch {
            if error.localizedDescription.starts(with: "Il y a eu des conflits en essayant de fusionner") {
                throw MergeError.mergeConflict
            }
            SentrySDK.capture(error: error)
            throw MergeError.error(message: error.localizedDescription)
        }
    }

    func nextConflict() throws -> MergeConflict {
        do {
            let conflict = try self.mergeConflicts.nextConflict()
            let left = try JSONDecoder().decode(ModelRelatedTuple.self,
                                                from: conflict.left.data(using: .utf8)!)
            let right = try JSONDecoder().decode(ModelRelatedTuple.self,
                                                 from: conflict.right.data(using: .utf8)!)
            return MergeConflict(key: conflict.key, left: left, right: right)
        } catch {
            if error.localizedDescription.starts(with: "Il n'y a pas de conflits non résolus") {
                throw MergeError.noConflicts
            }
            SentrySDK.capture(error: error)
            throw error
        }
    }
}
