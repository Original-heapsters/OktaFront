//
//  ARState.swift
//  CachAR
//
//  Created by Andrew Briare on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation

enum ARState: String, CustomStringConvertible {
    case initialized = "initialized"
    case ready = "ready"
    case temporarilyUnavailable = "temporarily unavailable"
    case failed = "failed"
    
    var description: String {
        switch self {
        case .initialized:
            return "👀 Look for a plane to place your object"
        case .ready:
            return "🔥 Click any plane to place your object"
        case .temporarilyUnavailable:
            return "😱 Calibrating. Please wait"
        case .failed:
            return "⛔️ Big problem! Please restart App."
        }
    }
}
