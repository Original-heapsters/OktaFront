//
//  MathHelpers.swift
//  CachAR
//
//  Created by Andrew Briare on 4/29/18.
//  Copyright © 2018 Andrew Briare. All rights reserved.
//

import Foundation
import UIKit

class MathHelpers {

    static func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }

    private static func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    static func deg2rad(deg: Double) -> Double {
        return deg * Double.pi / 180.0
    }

    static func rad2deg(rad: Double) -> Double {
        return rad * 180.0 / Double.pi
    }

    static func distance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist *= 60 * 1.1515
        dist *= 1609.344

        return dist
    }

}
