////
////  MapKitLocationSearch.swift
////  GameFrameIOS
////
////  Created by Mélina Rochon on 2025-03-06.
////
//
//import Foundation
//import MapKit
//
//class MapKitLocationSearch: NSObject, MKLocalSearchCompleterDelegate {
//
//    var searchCompleter = MKLocalSearchCompleter()
//    var matchingLocations: [MKMapItem] = []
//    var search: String = "" {
//        didSet {
//            searchCompleter.queryFragment = search
//        }
//    }
//    
//    var maxDisplay = 8
//    var suggestions = [MKLocalSearchCompletion]()
//    
//    override init() {
//        super.init()
//        
//        searchCompleter.delegate = self
//        searchCompleter.resultTypes = .address
//        
//    }
//    
//    func performSearch() async {
//        guard search.count > 3 else {
//            return // don't do a search if there's less than 3 characters
//        }
//        
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = search
//        let search = MKLocalSearch(request: request)
//        
//        if let match = try? await search.start() {
//            matchingLocations = match.mapItems
//        }
//        
//        matchingLocations = []
//        
//        await withTaskGroup(of: [MKMapItem].self) { group in
//            for suggestion in suggestions.prefix(maxDisplay) {
//                group.addTask {
//                    let suggestionRequest = MKLocalSearch.Request(completion: suggestion)
//                    let suggestionSearch = MKLocalSearch(request: suggestionRequest)
//                    
//                    if let response = try? await suggestionSearch.start() {
//                        return response.mapItems
//                    }
//                    return []
//
//                }
//            }
//            
//            for await mapItems in group {
//                matchingLocations.append(contentsOf: mapItems)
//            }
//        }
//    }
//    
//    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//        suggestions = completer.results
//        
//        Task {
//            await performSearch()
//        }
//    }
//}
