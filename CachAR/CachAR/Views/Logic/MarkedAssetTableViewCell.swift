//
//  MarkedAssetTableViewCell.swift
//  CachAR
//
//  Created by Andrew Briare on 4/29/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import UIKit

class MarkedAssetTableViewCell: UITableViewCell {

    public static var identifier: String = String(describing: MarkedAssetTableViewCell.self)

    var username: UILabel!
    var message: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
