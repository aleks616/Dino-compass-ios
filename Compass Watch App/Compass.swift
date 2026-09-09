//
//  Compass.swift
//  Compass
//
//  Created by Aleks Jankowiak on 02/09/2026.
//

import CoreLocation

final class Compass: NSObject, CLLocationManagerDelegate {
    
    protocol CompassListener: AnyObject {
        func onNewAzimuth(_ azimuth: Float)
    }
    
    private let locationManager = CLLocationManager()
    private weak var listener: CompassListener?
    private var targetDirection: Float = 0
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func start() {
        guard CLLocationManager.headingAvailable() else { return }
        locationManager.startUpdatingHeading()
    }
    
    func stop() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    func setListener(_ listener: CompassListener?) {
        self.listener = listener
    }
    
    func setLocation(_ userLocation: Location) {
        guard !dinoList.isEmpty else {
            print("dinoList is empty, cannot set target direction")
            return
        }
        
        guard let nearest = dinoList.min(by: { $0.getDistance(userLocation) < $1.getDistance(userLocation) }),
              let shopLocation = nearest.location else {return}
        
        
        let distance = nearest.getDistance(userLocation)
        //print("Nearest: \(nearest.address)")
        
        let userLat = userLocation.latitude.toRadians()
        let shopLat = shopLocation.latitude.toRadians()
        let deltaLon = (shopLocation.longitude - userLocation.longitude).toRadians()
        
        let y = sin(deltaLon) * cos(shopLat)
        let x = cos(userLat) * sin(shopLat) - sin(userLat) * cos(shopLat) * cos(deltaLon)
        
        var bearing = atan2(y, x).toDegrees()
        bearing = (bearing + 360).truncatingRemainder(dividingBy: 360)
        
        targetDirection = Float(bearing)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let magneticHeading = Float(newHeading.magneticHeading)
        guard magneticHeading >= 0 else { return }
        
        var azimuth = (targetDirection - magneticHeading + 360).truncatingRemainder(dividingBy: 360)
        if azimuth < 0 { azimuth += 360 }
        
        listener?.onNewAzimuth(azimuth)
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}

private extension Double {
    func toRadians() -> Double { self * .pi / 180.0 }
    func toDegrees() -> Double { self * 180.0 / .pi }
}
