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

    private var azimuthFix: Float = 0

    override init() {
        super.init()

        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
    }

    func start() {
        guard CLLocationManager.headingAvailable() else {
            return
        }

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
    }

    func stop() {
        locationManager.stopUpdatingHeading()
    }

    func setAzimuthFix(_ fix: Float) {
        azimuthFix = fix
    }

    func resetAzimuthFix() {
        azimuthFix = 0
    }

    func setListener(_ listener: CompassListener?) {
        self.listener = listener
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {
        let magneticHeading = newHeading.magneticHeading

        guard magneticHeading >= 0 else {
            return
        }

        let adjustedAzimuth = (
            Float(magneticHeading) + azimuthFix + 360
        )
        .truncatingRemainder(dividingBy: 360)

        listener?.onNewAzimuth(adjustedAzimuth)
    }

    func locationManagerShouldDisplayHeadingCalibration(
        _ manager: CLLocationManager
    ) -> Bool {
        true
    }
}
