//
//  LocationSearchService.swift
//  GameFrameIOS
//
//  Created by Mélina Rochon on 2025-03-06.
//

import Foundation
import MapKit

@Observable
class LocationSearchService: NSObject, CLLocationManagerDelegate {
    var query: String = "" {
        didSet {
            debounceSearch(query)
        }
    }
    
    var results: [LocationResult] = []
    var status: SearchStatus = .idle
    var completer: MKLocalSearchCompleter
    var coordinate: CLLocationCoordinate2D?
    private var debounceTimer: Timer?

    init(filter: MKPointOfInterestFilter = .includingAll, region: MKCoordinateRegion = MKCoordinateRegion(.world), types: MKLocalSearchCompleter.ResultType = [.pointOfInterest, .query, .address]) {
        completer = MKLocalSearchCompleter()
        
        super.init()
        completer.delegate = self
        completer.pointOfInterestFilter = filter
        completer.region = region
        completer.resultTypes = types
    }
    
    
    func updateCoordinate(newCoordinate: CLLocationCoordinate2D) {
        coordinate = newCoordinate
        
        
    }
    
    // Add debounce behavior to prevent multiple rapid searches
    private func debounceSearch(_ fragment: String) {
        debounceTimer?.invalidate()
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.handleSearchFragment(fragment)
        }
    }
    
    private func handleSearchFragment(_ fragment: String) {
        self.status = .searching
        if !fragment.isEmpty
            {
                self.completer.queryFragment = fragment
        } else {
            self.status = .idle
            self.results = []
        }
    }
    
    // Geocode only when user selects a result from the list
    func resolveFullDetails(for result: LocationResult) {
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(result.title) { (placemarks, error) in
                if let error = error {
                    print("Error geocoding address: \(error.localizedDescription)")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    print("No placemark found for the address")
                    return
                }
                
                print(placemark)
                // Create a LocationResult object with the full address and coordinates
                let fullAddress = placemark.name ?? "No address"
                let coordinates = placemark.location
                
                // Update only the selected result's details
                if let index = self.results.firstIndex(where: { $0.title == result.title && $0.subtitle == result.subtitle }) {
                    self.results[index].fullAddress = fullAddress
                    self.results[index].coordinates = coordinates?.coordinate
                }
                
                // Optionally, update the status to reflect that the search is complete
                DispatchQueue.main.async {
                    self.status = .result
                }
            }
        }
}


extension LocationSearchService: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map({ result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        })
        
        self.status = .result
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        self.status = .error(error.localizedDescription)
    }
}


struct LocationResult: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var fullAddress: String?
    var coordinates: CLLocationCoordinate2D?
    
    // Conform to Equatable
        static func ==(lhs: LocationResult, rhs: LocationResult) -> Bool {
            return lhs.id == rhs.id
        }

        // Conform to Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(title)
            hasher.combine(subtitle)
            hasher.combine(fullAddress)
            hasher.combine(coordinates?.latitude)
            hasher.combine(coordinates?.longitude)
        }
}

enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case result
}
