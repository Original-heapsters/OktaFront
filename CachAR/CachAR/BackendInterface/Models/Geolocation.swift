//
//  Geolocation.swift
//  CachAR
//
//  Created by Andrew Briare on 4/29/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation

class Geolocation {

    var latitude: Double = 0.0
    var longitude: Double = 0.0

    public var description: String {
        return "Latitude: \(latitude)   Longitude: \(longitude)"
    }

    init(lat: Double, long: Double) {
        latitude = lat
        longitude = long
    }

    init(geolocation: Geolocation) {
        latitude = geolocation.latitude
        longitude = geolocation.longitude
    }

    func applyOffset(x: Double, y: Double) {
        print("Original coordinates: \(self.description)")
        let earthRadius = Double(6378137)

        //Coordinate offsets in radians
        let dLat = x / earthRadius
        let dLon = y / (earthRadius * cos(Double.pi * latitude / 180))

        //OffsetPosition, decimal degrees
        latitude += dLat * 180 / Double.pi
        longitude += dLon * 180 / Double.pi

        print("New coordinates:      \(self.description)")
    }

}
