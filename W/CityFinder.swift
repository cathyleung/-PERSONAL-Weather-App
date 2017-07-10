//
//  CityFinder.swift
//  W
//
//  Created by Cathy Leung on 2017-05-18.
//  Copyright © 2017 Cathy Leung. All rights reserved.
//

import Foundation
import CoreLocation

protocol CoordinateFinderDelegate {
    func didGetCoordinate(coordinate: CLLocationCoordinate2D, location: String)
    func didNotGetCoordinate(error: NSError)
}

class CoordinateFinder {
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    lazy var geocoder = CLGeocoder()
    
    private var delegate: CoordinateFinderDelegate
    
    init(delegate: CoordinateFinderDelegate) {
        self.delegate = delegate
    }
/*
    func getCity(lat: Double, lon: Double) {
        latitude = lat
        longitude = lon
        
        let location: CLLocation = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            
            addressDict.forEach { print($0) }
        })
    }
*/
    func getCoordinates(city: String) {
        geocoder.geocodeAddressString(city, completionHandler: { placemarks, error in
            self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            print("Unable to Find Location for Address")
            self.delegate.didNotGetCoordinate(error: error as NSError)
            
        } else {
            var placemark: CLPlacemark!
            var location: CLLocation?
            var locationName: String!
            
            if let placemarks = placemarks, placemarks.count > 0 {
                placemark = placemarks.first
                location = placemarks.first?.location
                locationName = ""
                
                if (placemark.addressDictionary?["City"] != nil) {
                    locationName.append(placemark.locality! + " ")
                }
                
                if (placemark.addressDictionary?["State"] != nil) {
                    locationName.append(placemark.administrativeArea!)
                }
                
                if (placemark.addressDictionary?["Country"] != nil) {
                    if placemark.addressDictionary?["State"] != nil {
                        locationName.append(" ")
                    }
                    
                    if (placemark.addressDictionary?["City"] == nil) {
                        locationName.append(placemark.country!)
                    }
                }
            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("\(coordinate.latitude), \(coordinate.longitude)")
                self.delegate.didGetCoordinate(coordinate: coordinate, location: locationName)
            } else {
                print("No Matching Location Found")
                let err = NSError()
                self.delegate.didNotGetCoordinate(error: err)
            }
        }
    }
}
