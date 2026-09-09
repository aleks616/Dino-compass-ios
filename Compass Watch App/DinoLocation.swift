//
//  DinoLocation.swift
//  Compass
//
//  Created by Aleks Jankowiak on 09/09/2026.
//
import Foundation


class DinoLocation {
    let id:Int
    let address:String
    let street:String
    let city:String
    var location:Location?
    let zipCode:String

    init(_ id1:Int,_ address1:String,_ street1:String,_ city1:String,_ locationP:Location,_ zipCode1:String) {
        self.id=id1
        self.address=address1
        self.street=street1
        self.city=city1
        self.location=locationP
        self.zipCode=zipCode1
    }

   func getDistance(_ userLocation: Location) -> Double {
           let earthRadius = 6371.0
           let deltaLat = (self.location!.latitude - userLocation.latitude) * (Double.pi / 180)
           let deltaLng = (self.location!.longitude - userLocation.longitude) * (Double.pi / 180)

           let a =
               sin(deltaLat / 2) * sin(deltaLat / 2) +
               cos(self.location!.latitude * (Double.pi / 180)) *
               cos(userLocation.latitude * (Double.pi / 180)) *
               sin(deltaLng / 2) * sin(deltaLng / 2)

           let centralAngle = 2 * atan2(sqrt(a), sqrt(1 - a))
           let result = earthRadius * centralAngle

           return result.round(2)
       }
}

extension Double {
    func round(_ decimals:Int)->Double {
        var multiplier=1.0
        for _ in 0..<decimals {multiplier*=10}
        return (self*multiplier).rounded()/multiplier
    }
}
