//
//  AssetMarker.swift
//  CachAR
//
//  Created by Andrew Briare on 4/29/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import UIKit

class AssetMarker: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var textEntryField: UITextField!
    @IBOutlet weak var buttonMark: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Setup view from .xib file
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Setup view from .xib file
        xibSetup()
    }

    func xibSetup() {
        backgroundColor = UIColor.clear
        loadNib()
    }

    /** Loads instance from nib with the same name. */
    func loadNib() {
        Bundle.main.loadNibNamed(String(describing: AssetMarker.self), owner: self, options: nil)
        addSubview(view)
        view.frame = self.bounds
        view.layer.cornerRadius = 8
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        buttonMark.isEnabled = false

        let nib = UINib(nibName: "MarkedAssetTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MarkedAssetTableViewCell.identifier)

//        tableView.delegate = tableViewDelegate
//        tableView.dataSource = tableViewDelegate
    }

    @IBAction func textEntryChanged(_ sender: Any) {

    }

    @IBAction func textEntryEditingChanged(_ sender: Any) {
        guard let enteredText = textEntryField.text else {
            buttonMark.isEnabled = false
            return
        }

        buttonMark.isEnabled = enteredText.count > 0
    }

    @IBAction func markButtonClicked(_ sender: Any) {

    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        removeFromSuperview()
    }
}
