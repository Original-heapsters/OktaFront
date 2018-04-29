//
//  SignInViewController.swift
//  CachAR
//
//  Created by Andrew Briare on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import UIKit

class SignInViewController: UIViewController {
    let cacheBack = CacheBack()

    @IBAction func closeButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func postUserClicked(_ sender: Any) {
        self.cacheBack.postUser()
    }
    @IBAction func getUserClicked(_ sender: Any) {
        self.cacheBack.getUser()
    }
    @IBAction func placeClicked(_ sender: Any) {
        self.cacheBack.placeAsset()
    }
    @IBAction func getNearbyClicked(_ sender: Any) {
        self.cacheBack.getNearbyAssets()
    }

    @IBAction func findClicked(_ sender: Any) {
        self.cacheBack.getAsset()
    }
    @IBAction func markClicked(_ sender: Any) {
        self.cacheBack.markAsset()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.cacheBack.setup()
    }
}
