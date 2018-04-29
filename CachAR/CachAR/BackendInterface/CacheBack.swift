//
//  CacheBack.swift
//  CachAR
//
//  Created by Russell Tan on 4/28/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import Alamofire
import OktaAuth
import Zip

protocol oktaDelegate {
    func triggerLogin()
}

class CacheBack {
    var userId: String?
    var userFName: String?
    var userLName: String?
    var settings: NSDictionary?
    var delegate: oktaDelegate?
    func setup() {
        if let path = Bundle.main.path(forResource: "backendSettings", ofType: "plist") {
            if let dictRoot = NSDictionary(contentsOfFile: path) {
                self.settings = dictRoot
            }
        }
    }

    func checkLogin(whenValidated: @escaping () -> Void) {
        if let currentToken = OktaAuth.tokens?.get(forKey: "accessToken") {
            OktaAuth
                .introspect()
                .validate(currentToken) {
                    response, error in

                    if error != nil {
                        print("Error: \(error!)")
                        self.delegate?.triggerLogin()
                    }

                    if let isValid = response {
                        if !isValid {
                            // Token is not valid, prompt the user to login
                            self.delegate?.triggerLogin()
                        } else {
                            whenValidated()
                        }
                    }
            }
        } else {
           self.delegate?.triggerLogin()
        }
    }

    func postUser(_ userId: String, _ firstName: String, _ lastName: String, _ radiusSettings: String="20") {

        guard self.settings != nil else {
            return
        }
        let baseUrl = self.settings!["baseUrl"] as! String
        let endPoint = self.settings!["userEndpoint"] as! String
        let requestString = baseUrl + endPoint

        let parameters = [
            "userId": userId,
            "username": userId,
            "firstName": firstName,
            "lastName": lastName,
            "radius": radiusSettings
        ]

        Alamofire.request(requestString, method: .post, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            switch response.result {
            case .success:
                print("RESPONSE \(response.value)")

            case .failure(let error):
                print("RESPONSE \(error)")
            }
        }
    }

    func getUser(_ userId: String) {
        guard self.settings != nil else {
            return
        }
        let baseUrl = self.settings!["baseUrl"] as! String
        let endPoint = self.settings!["userEndpoint"] as! String
        let requestString = baseUrl + endPoint

        let parameters = [
            "userId": userId
        ]

        Alamofire.request(requestString, method: .get, parameters: parameters, encoding: URLEncoding(destination: .queryString)).responseJSON { response in
            switch response.result {
            case .success:
                print("RESPONSE \(response.value)")

            case .failure(let error):
                print("RESPONSE \(error)")
            }
        }

    }

    func placeAsset(_ userId: String, _ assetId: URL) {
        guard self.settings != nil else {
            return
        }
        let baseUrl = self.settings!["baseUrl"] as! String
        let endPoint = self.settings!["placeEndpoint"] as! String
        let requestString = baseUrl + endPoint

        let parameters = [
            "userId": userId,
            "lat": "100",
            "lon": "20",
            "assetType": "model"
        ]

        let headers: HTTPHeaders = [
            /* "Authorization": "your_access_token",  in case you need authorization header */
            "Content-type": "multipart/form-data"
        ]
        var modelData: Data? = nil
        do {
            let zipPath = try Zip.quickZipFiles([assetId], fileName: "asset")

            modelData = try Data(contentsOf: zipPath)
        } catch {

        }
        Alamofire.upload(multipartFormData: { multipartFormData in

            multipartFormData.append(userId.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "userId")
            multipartFormData.append("100".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "lat")
            multipartFormData.append("50".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "lon")
            multipartFormData.append("image".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "assetType")
            multipartFormData.append(modelData!, withName: "asset", fileName: "asset.zip", mimeType: "application/zip")
        }, usingThreshold: UInt64.init(), to: requestString, method: .post, headers: nil) { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print(response)
                    if let err = response.error {
                        print(err)
                    }
                    print(response.value)

                }
            case .failure(let encodingError):
                print(encodingError)
            }
        }

    }

    func getNearbyAssets() {

    }

    func getAsset() {

    }

    func markAsset() {

    }
}
