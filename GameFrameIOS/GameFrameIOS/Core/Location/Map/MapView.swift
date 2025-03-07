//
//  MapView.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    let cameraPosition: MapCameraPosition = .region(.init(center: .init(latitude: 37.3346, longitude: -122.0090), latitudinalMeters: 1300, longitudinalMeters: 1300))
    
    let startPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 56, longitude: -3), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
    
    let locationManager = CLLocationManager()
    
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var isLookingAround = false
    @State private var route: MKRoute?
    @State private var location: String = ""
    
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        TextField("Enter a location", text: $location).textContentType(.location)
        Map(initialPosition: cameraPosition) {
            //Marker("Apple HQ", systemImage: "laptopcomputer", coordinate: .appleHQ)
            
            
            // To make custom markers
            Annotation("YApple HQ", coordinate: .appleHQ, anchor: .bottom) {
                Image(systemName: "laptopcomputer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.purple.gradient, in: .circle)
                    .contextMenu {
                        Button("Open Look Around", systemImage: "binoculars") {
                            Task {
                                lookAroundScene = await getLookAroundScene(from: .appleVisitorCenter)
                                guard lookAroundScene != nil else { return } // won't execute until its done
                                isLookingAround = true
                            }
                        }
                        
                        Button("Get Directions", systemImage: "arrow.turn.down.right") {
                            getDirections(to: .appleVisitorCenter)
                        }
                    }
            }
            
            UserAnnotation()
            
            if let route {
                MapPolyline(route)
                    .stroke(Color.pink, lineWidth: 4)
            }
            
        }
        .onAppear {
            // Ask user to get their location
            locationManager.requestWhenInUseAuthorization()
        }
        .mapControls {
            // Basic map controls
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
            
            
        }
        .lookAroundViewer(isPresented: $isLookingAround, initialScene: lookAroundScene)
        .mapStyle(.standard(elevation: .realistic))
    }
    
    func getLookAroundScene(from coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        do {
            return try await MKLookAroundSceneRequest(coordinate: coordinate).scene
        } catch {
            print("Cannot retrieve Look Around scene: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserLocation() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()
        
        do {
            let update = try await updates.first{
                // $0. - all elements in the list
                $0.location?.coordinate != nil
            }
            return update?.location?.coordinate
        } catch {
            print("Cannot get user location")
            return nil
        }
    }
    
    func getDirections(to destination: CLLocationCoordinate2D) {
        Task {
            guard let userLocation = await getUserLocation() else { return }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: userLocation))
            request.destination = MKMapItem(placemark: .init(coordinate: destination))
            request.transportType = .walking
            
            do {
                let directions = try await MKDirections(request: request).calculate()
                route = directions.routes.first
            } catch {
                print("Show error ")
            }
        }
    }
}

#Preview {
    MapView()
}

extension CLLocationCoordinate2D {
    static let appleHQ = CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
    static let appleVisitorCenter = CLLocationCoordinate2D(latitude: 37.332753, longitude: -122.005372)

}
