//
//  Trip.swift
//  UBER
//
//  Created by Long Nguyen on 4/23/21.
//

import UIKit
import CoreLocation

enum TripState: Int {
    case requested
    case accepted
    case inProgressed
    case completed
}

struct Trip {
    
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    let passengerUid: String!
    var driverUid: String?
    var state: TripState!
    
    init?(riderUID: String, dict: [String : Any]) {
        
        if let pickupCoor = dict["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoor[0] as? CLLocationDegrees else {
                print("DEBUG: no latitude pickup..")
                return nil
            }
            guard let long = pickupCoor[1] as? CLLocationDegrees else {
                print("DEBUG: no longtitude pickup..")
                return nil
            }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let destinationCoor = dict["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoor[0] as? CLLocationDegrees else {
                print("DEBUG: no latitude destination..")
                return nil
            }
            guard let long = destinationCoor[1] as? CLLocationDegrees else{
                print("DEBUG: no longtitude destination..")
                return nil
            }
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        if let currentState = dict["state"] as? Int {
            self.state = TripState(rawValue: currentState)
        }
        
        self.passengerUid = riderUID
        self.driverUid = dict["driverUid"] as? String ?? "no driver"
        
    }
    
}


