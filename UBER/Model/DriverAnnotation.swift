//
//  DriverAnnotation.swift
//  UBER
//
//  Created by Long Nguyen on 4/20/21.
//

import UIKit
import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D //make this "dynamic" so that the driver's annotation moves around on the map
    var driverUid: String
    
    init(uidDriver: String, coordinateDriver: CLLocationCoordinate2D) {
        self.driverUid = uidDriver
        self.coordinate = coordinateDriver
    }
    
    func updateAnnotationPosition(newCoordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 2) {
            self.coordinate = newCoordinate //let's move the driver's position on the map
        }
    }
}
