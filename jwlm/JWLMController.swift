//
//  JwlmController.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//  Copyright © 2020 Andreas Skorczyk. All rights reserved.
//

import Foundation
import Gomobile

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
}

class MergeProgress: ObservableObject {
    @Published var status: String = ""
    @Published var percent: Float = 0
}

enum MergeError: Error {
    case notInitialized(message: String)
    case mergeConflict
    case noConflicts
    case error(message: String)
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
        self.settings = MergeSettings(bookmarkResolver: .disabled, markingResolver: .disabled, noteResolver: .disabled)
    }

    func importBackup(url: URL, side: MergeSide) throws {
        _ = url.startAccessingSecurityScopedResource()
        try dbWrapper.importJWLBackup(url.path, side: side.rawValue)
        url.stopAccessingSecurityScopedResource()
        cleanUpInbox()
    }

    func exportBackup() throws -> String {
        cleanUpMergedFiles()
        if !self.dbWrapper.dbIsLoaded("mergeSide") {
            throw MergeError.notInitialized(message: "There is no merged backup yet")
        }

        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filename = "merged" + String(Int(NSDate().timeIntervalSince1970)) + ".jwlibrary"
        let path = dir?.appendingPathComponent(filename).path

        try dbWrapper.exportMerged(path)

        return path!
    }

    // cleanUpMergedFiles removes all files starting with `merged` from the documentDirectory,
    // as they are the result of older merges
    func cleanUpMergedFiles() {
        let fm = FileManager.default
        do {
            let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first
            let files = try fm.contentsOfDirectory(at: dir!.absoluteURL,
                                                   includingPropertiesForKeys: [.isRegularFileKey])
            for file in files {
                if file.lastPathComponent.hasPrefix("merged") {
                    try fm.removeItem(at: file)
                    print("Cleaning up \(file.absoluteString)")
                }
            }
        } catch {
            print("Error while trying to clean up old files")
        }
    }

    // cleanUpInbox removes all files inside the inbox
    func cleanUpInbox() {
        let fm = FileManager.default
        do {
            let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Inbox")
            let files = try fm.contentsOfDirectory(at: dir!.absoluteURL,
                                                   includingPropertiesForKeys: [.isRegularFileKey])
            for file in files {
                try fm.removeItem(at: file)
                print("Cleaning up \(file.absoluteString)")
            }
        } catch {
            print("Error while trying to clean up inbox")
        }
    }

    func merge(reset: Bool = true, progress: MergeProgress) throws {
        if !self.dbWrapper.dbIsLoaded(MergeSide.leftSide.rawValue)
           || !self.dbWrapper.dbIsLoaded(MergeSide.rightSide.rawValue) {
            throw MergeError.notInitialized(message: "At least one backup has not been imported yet")
        }
        if reset {
            mergeConflicts = GomobileMergeConflictsWrapper()
            mergeConflicts.initDBWrapper(dbWrapper)
        }

        dbWrapper.init_()

        do {
            progress.percent = 16
            progress.status = "Merging Locations"
            try dbWrapper.mergeLocations()

            progress.percent = 32
            progress.status = "Merging Bookmarks"
            try dbWrapper.mergeBookmarks(self.settings.bookmarkResolver.rawValue, mcw: self.mergeConflicts)

            progress.percent = 48
            progress.status = "Merging Tags"
            try dbWrapper.mergeTags()

            progress.percent = 64
            progress.status = "Merging Markings"
            try dbWrapper.mergeUserMarkAndBlockRange(self.settings.markingResolver.rawValue, mcw: self.mergeConflicts)

            progress.percent = 80
            progress.status = "Merging Notes"
            try dbWrapper.mergeNotes(self.settings.noteResolver.rawValue, mcw: self.mergeConflicts)

            progress.percent = 96
            progress.status = "Merging TagMaps"
            try dbWrapper.mergeTagMaps()

            progress.percent = 100
            progress.status = "Done"
        } catch {
            if error.localizedDescription.starts(with: "There were conflicts while trying to merge") {
                throw MergeError.mergeConflict
            }
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
            if error.localizedDescription.starts(with: "There are no unsolved conflicts") {
                throw MergeError.noConflicts
            }
            throw error
        }
    }
}
