////
////  LocationViewModel.swift
////  GameFrameIOS
////
////  Created by Mélina Rochon on 2025-03-06.
////
//
//import Foundation
//import MapKit
//import SwiftUI
//
//@Observable
//class VM {
//    var mapKitSearch = MapKitLocationSearch()
//    var annotationTitle = ""
//    var coordinate: CLLocationCoordinate2D = .initialLocation
//    var mapSpan: MKCoordinateSpan = .initialSpan
//    var camera: MapCameraPosition = .region(.init(center: .initialLocation, span: .initialSpan))
//    var updateCamera = false
//    
//    func updateCoordinate(newCoordinate: CLLocationCoordinate2D) {
//        coordinate = newCoordinate
//        if updateCamera {
//            withAnimation(.smooth) {
//                camera = .region(MKCoordinateRegion(center: coordinate, span: mapSpan))
//            }
//        }
//    }
//    
//    func updateMapSpan(newspan: MKCoordinateSpan) {
//        mapSpan = newspan
//        
//    }
//    
//    func selectLocation(_ location: MKMapItem) {
//        guard let newCoordinate = location.placemark.location?.coordinate else { return }
//        
//        coordinate = newCoordinate
//        updateCamera = true
//        withAnimation(.smooth) {
//            camera = .region(MKCoordinateRegion(center: coordinate, span: mapSpan))
//        }
//        
//        findCoordinate()
//    }
//    
//    func findCoordinate() {
//        annotationTitle = ""
//        Task {
//            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            
//            let geocoder = CLGeocoder()
//            if let name = try? await geocoder.reverseGeocodeLocation(location).first?.name {
//                annotationTitle = name
//            }
//        }
//    }
//}
//
//extension MKCoordinateSpan {
//    static var initialSpan: MKCoordinateSpan {
//        return .init(latitudeDelta: 0.07, longitudeDelta: 0.07)
//    }
//}
//
//extension CLLocationCoordinate2D {
//    static var initialLocation: CLLocationCoordinate2D {
//        return .init(latitude: 45.5236, longitude: 4.8357)
//    }
//}
