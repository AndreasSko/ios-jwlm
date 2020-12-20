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
