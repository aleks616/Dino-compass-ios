//
//  ContentView.swift
//  Compass Watch App
//
//  Created by Aleks Jankowiak on 02/09/2026.
//

import SwiftUI

final class CompassViewModel: NSObject, ObservableObject, Compass.CompassListener {

    @Published var handRotation: Double = 0
    @Published var directionText = "xxx NN"

    private let compass = Compass()
    private let formatter = SOTWFormatter()
    private var currentAzimuth: Float = 0

    override init() {
        super.init()
        compass.setListener(self)
    }

    func start() {
        compass.start()
    }

    func stop() {
        compass.stop()
    }

    func onNewAzimuth(_ azimuth: Float) {
        DispatchQueue.main.async {
            var delta = (azimuth - self.currentAzimuth)
                .truncatingRemainder(dividingBy: 360)

            if delta > 180 {
                delta -= 360
            } else if delta < -180 {
                delta += 360
            }

            self.currentAzimuth += delta

            withAnimation(.easeInOut(duration: 0.5)) {
                self.handRotation = -Double(self.currentAzimuth)
                self.directionText = self.formatter.format(azimuth)
            }
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
