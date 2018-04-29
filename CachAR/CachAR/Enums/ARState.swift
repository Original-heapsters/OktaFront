//
//  ARState.swift
//  CachAR
//
//  Created by Andrew Briare on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation

enum ARState: String, CustomStringConvertible {
    case initializing = "initializing"
    case initialized = "initialized"
    case ready = "ready"
    case temporarilyUnavailable = "temporarily unavailable"
    case failed = "failed"

    var description: String {
        switch self {
        case .initializing:
            return "🙏 AR starting up!"
        case .initialized:
            return "😍 AR ready!"
        case .ready:
            return "🔥 Media can be placed!"
        case .temporarilyUnavailable:
            return "😱 Calibrating. Please wait"
        case .failed:
            return "⛔️ Big problem! Please restart App."
        }
    }
}
