//
//  CacheBack.swift
//  CachAR
//
//  Created by Russell Tan on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import Alamofire

class CacheBack {
    var settings: NSDictionary?
    func setup() {
        if let path = Bundle.main.path(forResource: "backendSettings", ofType: "plist") {
            if let dictRoot = NSDictionary(contentsOfFile: path) {
                self.settings = dictRoot
            }
        }
    }

    func postUser() {
        guard self.settings != nil else {
            return
        }
        let baseUrl = self.settings!["baseUrl"] as! String
        let endPoint = self.settings!["userEndpoint"] as! String
        let requestString = baseUrl + endPoint

        let parameters = [
            "userId": "jhdsfksdh7429837429",
            "username": "Paul",
            "radius": "10"
        ]

        Alamofire.request(requestString, method: .post, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            print("RESPONSE \(response.result.value ?? "val")")
            print("RESPONSE \(response.result)")
            print("RESPONSE \(response)")

            switch response.result {
            case .success:
                print("RESPONSE \(response.result)")

            case .failure(let error):
                print("RESPONSE \(error)")
            }
        }
    }

    func getUser() {

    }

    func placeAsset() {

    }

    func getNearbyAssets() {

    }

    func getAsset() {

    }

    func markAsset() {

    }
}
