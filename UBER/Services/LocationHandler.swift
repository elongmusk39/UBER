//
//  LocationHandler.swift
//  UBER
//
//  Created by Long Nguyen on 4/19/21.
//

import UIKit
import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationHandler()
    var locationManager: CLLocationManager!
    var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    //let's evaluate the case from HomeVC
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            print("DEBUG: current status is whenInUse, requesting always")
            locationManager.requestAlwaysAuthorization() //ask user 2 things (always allow or allow when app is used)
        } else if status == .authorizedAlways {
            print("DEBUG: current status is always")
        }
    }
    
    
    
}
