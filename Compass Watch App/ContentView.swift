//
//  ContentView.swift
//  Compass Watch App
//
//  Created by Aleks Jankowiak on 02/09/2026.
//

import SwiftUI
import CoreLocation

final class CompassViewModel: NSObject, ObservableObject, Compass.CompassListener {
    
    @Published var handRotation: Double = 0
    @Published var directionText = "xxx NN"
    
    private let compass = Compass()
    private let formatter = SOTWFormatter()
    private var currentAzimuth: Float = 0
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        compass.setListener(self)
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        loadData()
    }
    
    func start() {
        compass.start()
        checkLocationAuthorization()
    }
    
    func stop() {
        compass.stop()
        locationManager.stopUpdatingLocation()
    }
    
    func onNewAzimuth(_ azimuth: Float) {
        DispatchQueue.main.async {
            var delta = (azimuth - self.currentAzimuth)
                .truncatingRemainder(dividingBy: 360)
            if delta > 180 { delta -= 360 }
            else if delta < -180 { delta += 360 }
            
            self.currentAzimuth += delta
            
            withAnimation(.easeInOut(duration: 0.5)) {
                self.handRotation = -Double(self.currentAzimuth)
                self.directionText = self.formatter.format(azimuth)
            }
        }
    }
    
    private func loadData() {
        guard let url = Bundle.main.url(forResource: "data", withExtension: nil) else {
            print("Data file not found")
            return
        }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("Failed to read data")
            return
        }
        
        let pattern = #"(\d+),"([^"]*)","([^"]*)","([^"]*)",Location\(([-\d.]+),([-\d.]+)\),"([^"]*)""#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            print("Invalid regex")
            return
        }
        
        content.enumerateLines { line, _ in
            let range = NSRange(line.startIndex..., in: line)
            guard let match = regex.firstMatch(in: line, range: range) else { return }
            let id = Int(line[Range(match.range(at: 1), in: line)!])!
            let address = String(line[Range(match.range(at: 2), in: line)!])
            let street = String(line[Range(match.range(at: 3), in: line)!])
            let city = String(line[Range(match.range(at: 4), in: line)!])
            let lat = Double(line[Range(match.range(at: 5), in: line)!])!
            let lon = Double(line[Range(match.range(at: 6), in: line)!])!
            let zip = String(line[Range(match.range(at: 7), in: line)!])
            let location = Location(latitude: lat, longitude: lon)
            let dino = DinoLocation(id, address, street, city, location, zip)
            dinoList.append(dino)
        }
        print("Loaded \(dinoList.count) shops")
    }
    
    private func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            // Try to start updating immediately – if not authorized, it will fail silently,
            // but once permission is granted, it should work.
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    private func setupCompass(with clLocation: CLLocation) {
        let userLocation = Location(
            latitude: clLocation.coordinate.latitude,
            longitude: clLocation.coordinate.longitude
        )
        compass.setLocation(userLocation)
    }
}

extension CompassViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        setupCompass(with: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
}

struct ContentView: View {

    @StateObject private var viewModel = CompassViewModel()

    var body: some View {
        GeometryReader { geometry in
            let compassSize = min(
                geometry.size.width,
                geometry.size.height
            ) * 1
           VStack{
              ZStack {
                  Image("dial2")
                      .resizable()
                      .scaledToFit()
                      .frame(
                          width: compassSize,
                          height: compassSize
                      )

                  Image("hands2")
                      .resizable()
                      .scaledToFit()
                      .frame(
                          width: compassSize * 0.85,
                          height: compassSize * 0.85
                      )
                      .rotationEffect(
                          .degrees(viewModel.handRotation)
                      )
              }
             Text(viewModel.directionText)
                 .font(.caption2)
                 .padding(4)
           }
           .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .center
        )
            
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

#Preview {
    ContentView()
}
public import Combine
