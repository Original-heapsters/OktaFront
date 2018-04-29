//
//  Mark.swift
//  CachAR
//
//  Created by Russell Tan on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import SwiftyJSON

class Mark {

    var idMark: String!
    var user: String!
    var note: String!

    init() {

    }

    init(jsonRep: [String: Any]) {
        let js = JSON(jsonRep)
        self.idMark = js["idMark"].stringValue
        self.user = js["user"].stringValue
        self.note = js["note"].stringValue
    }
}
