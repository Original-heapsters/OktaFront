//
//  User.swift
//  CachAR
//
//  Created by Russell Tan on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import SwiftyJSON

class User {

    var userId: String!
    var firstName: String!
    var lastName: String!
    var radiusSettings: String!

    init(jsonRep: [String: Any]) {
        let js = JSON(jsonRep)
        self.userId = js["id"].stringValue
        self.firstName = js["firstName"].stringValue
        self.lastName = js["lastName"].stringValue
        self.radiusSettings = js["radiusSettings"].stringValue
    }
}
