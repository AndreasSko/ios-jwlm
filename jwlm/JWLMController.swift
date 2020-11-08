//
//  JwlmController.swift
//  jwlm
//
//  Created by Andreas Skorczyk on 11.10.20.
//  Copyright © 2020 Andreas Skorczyk. All rights reserved.
//

import Foundation
import Gomobile

enum mergeSide: String {
    case leftSide = "leftSide"
    case rightSide = "rightSide"
}

enum conflictSolver: String {
    case disabled = ""
    case chooseLeft = "chooseLeft"
    case chooseRight = "chooseRight"
    case chooseNewest = "chooseNewest"
}

struct mergeSettings {
    var bookmarkResolver: conflictSolver
    var markingResolver: conflictSolver
    var noteResolver: conflictSolver
}

class MergeProgress: ObservableObject {
    @Published var status: String = ""
    @Published var percent: Float = 0
}

enum MergeError: Error {
    case notInitialized(message: String)
    case mergeConflict
    case error(message: String)
}

class JWLMController: ObservableObject {
    var dbWrapper: GomobileDatabaseWrapper
    var mergeConflicts: GomobileMergeConflictsWrapper
    var settings: mergeSettings
    
    private var solvedConflicts = 0
    
    init() {
        self.dbWrapper = GomobileDatabaseWrapper()
        self.mergeConflicts = GomobileMergeConflictsWrapper()
        self.mergeConflicts.initDBWrapper(dbWrapper)
        self.settings = mergeSettings(bookmarkResolver: .disabled, markingResolver: .disabled, noteResolver: .disabled)
    }
    
    func importBackup(url: URL, side: mergeSide) throws {
        _ = url.startAccessingSecurityScopedResource()
        try dbWrapper.importJWLBackup(url.path, side: side.rawValue)
        url.stopAccessingSecurityScopedResource()
    }
    
    func exportBackup() throws -> String {
        if !self.dbWrapper.dbIsLoaded("mergeSide") {
            throw MergeError.notInitialized(message: "There is no merged backup yet")
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filename = "merged" + String(Int(NSDate().timeIntervalSince1970)) + ".jwlibrary"
        let path = dir?.appendingPathComponent(filename).path
        
        try dbWrapper.exportMerged(path)
        
        return path!
    }
    
    func merge(reset: Bool = true, progress: MergeProgress) throws {
        if !self.dbWrapper.dbIsLoaded(mergeSide.leftSide.rawValue)
           || !self.dbWrapper.dbIsLoaded(mergeSide.rightSide.rawValue){
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
        }
        catch {
            if error.localizedDescription.starts(with: "There were conflicts while trying to merge") {
                throw MergeError.mergeConflict
            }
            throw MergeError.error(message: error.localizedDescription)
        }
    }
    
    func nextConflictID() -> Int {
        return mergeConflicts.getNextConflictIndex()
    }
}

