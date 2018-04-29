//
//  Asset.swift
//  CachAR
//
//  Created by Russell Tan on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import SwiftyJSON
import Zip

class Asset {

    var id: String!
    var owner: String!
    var link: String!
    var type: String!
    var location: String!
    var marks: [Mark] = [Mark]()
    var diskURL: URL?

    init(jsonRep: [String: Any]) {
        let js = JSON(jsonRep)
        self.id = js["assetId"].stringValue
        self.owner = js["owner"].stringValue
        self.link = js["link"].stringValue
        if self.link != "" {
            CacheBack.downloadAsset(self.id, self.link, completionHandler: { destUrl in
                do {
                    let unzipDirectory = try Zip.quickUnzipFile(destUrl)
                    print(unzipDirectory)
                } catch {

                }
                self.diskURL = destUrl
            })
        }
        self.type = js["type"].stringValue
        self.location = js["latlon"].stringValue
        if let items = js["markedList"].array {
            for mark in items {
                var marker = Mark()
                marker.note = mark["note"].stringValue
                marker.user = mark["userId"].stringValue
                self.marks.append(marker)
            }
        }
    }
}
