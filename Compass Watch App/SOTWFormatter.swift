//
//  SOTWFormatter.swift
//  Compass
//
//  Created by Aleks Jankowiak on 02/09/2026.
//


import Foundation

final class SOTWFormatter {

    private static let sides = [0, 45, 90, 135, 180, 225, 270, 315, 360]

    private static let names = [
        "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"
    ]

    func format(_ azimuth: Float) -> String {
        let integerAzimuth = Int(azimuth)
        let index = findClosestIndex(to: integerAzimuth)

        return "\(integerAzimuth)° \(Self.names[index])"
    }

    private func findClosestIndex(to target: Int) -> Int {
        var i = 0
        var j = Self.sides.count
        var mid = 0

        while i < j {
            mid = (i + j) / 2

            if target < Self.sides[mid] {
                if mid > 0 && target > Self.sides[mid - 1] {
                    return getClosest(
                        index1: mid - 1,
                        index2: mid,
                        target: target
                    )
                }

                j = mid
            } else {
                if mid < Self.sides.count - 1 &&
                    target < Self.sides[mid + 1] {
                    return getClosest(
                        index1: mid,
                        index2: mid + 1,
                        target: target
                    )
                }

                i = mid + 1
            }
        }

        return mid
    }

    private func getClosest(
        index1: Int,
        index2: Int,
        target: Int
    ) -> Int {
        if target - Self.sides[index1] >= Self.sides[index2] - target {
            return index2
        }

        return index1
    }
}
