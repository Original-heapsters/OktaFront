//
//  Asset.swift
//  CachAR
//
//  Created by Russell Tan on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import SwiftyJSON

class Asset {

    var id: String!
    var owner: String!
    var link: String!
    var type: String!
    var location: String!
    var diskURL: URL?

    init(jsonRep: [String: Any]) {
        let js = JSON(jsonRep)
        self.id = js["id"].stringValue
        self.owner = js["owner"].stringValue
        self.link = js["link"].stringValue
        if self.link != "" {
            CacheBack.downloadAsset(self.link, completionHandler: { destUrl in
                self.diskURL = destUrl
            })
        }
        self.type = js["type"].stringValue
        self.location = js["latlon"].stringValue
    }
}
