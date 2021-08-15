//
//  Service.swift
//  UBER
//
//  Created by Long Nguyen on 4/19/21.
//

import UIKit
import Firebase
import CoreLocation //from external module
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    
    static let shared = Service()
    let currentEmail = Auth.auth().currentUser?.email ?? "no email"
    
    /*
    //this is what fetching user data like a noob
    func fetchUserData(completion: @escaping(String) -> Void) {
        print("DEBUG: fetching data user \(currentEmail)..")
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return } //put all user's info into the dictionary
            let fullnameFetched = dictionary["fullname"] ?? "no name"
            print("DEBUG: user fullname is \(fullnameFetched)")
            
            completion(fullnameFetched as! String)
        }
    }
    */
    
    //let's fetch user data
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        print("DEBUG: fetching data user \(currentEmail)..")
        
        //the 'observe' down below only fetch the data one time
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return } //put all user's info into the dictionary
            let userID = snapshot.key
            let userFetched = User(uid: userID, dictionary: dict)
            completion(userFetched)
        }
    }
    
    //let's fetch driver's info and display it within a radius
    func fetchDriver(locationRider: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        
        //since we use "observe" stuff, everytime the location in the database changes, the func below gets called
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            
            geofire.query(at: locationRider, withRadius: 50).observe(.keyEntered, with: { (UIDdriver, locationDriver) in
                
                print("DEBUG: uid \(UIDdriver) and location \(locationDriver)")
                self.fetchUserData(uid: UIDdriver) { (userInfo) in
                    var driver = userInfo
                    driver.location = locationDriver //pass in data about the location of Driver to "driver.location"
                    completion(driver)
                }
                
            })
        }
        
    }
    
    
    func uploadTrip(pickupCoor: CLLocationCoordinate2D, destinationCoor: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("DEBUG: no UID, user not logged in..")
            return
        }
        guard let riderMail = Auth.auth().currentUser?.email else { return }
        
        let pickupArray = [pickupCoor.latitude, pickupCoor.longitude]
        let destinationArray = [destinationCoor.latitude, destinationCoor.longitude]
        
        let values = ["riderEmail": riderMail,
                      "pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(currentUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    
    func observeTrips(completion: @escaping(Trip) -> Void) {
        //if a "child" is added to the database, then this func will notice and do something cool
        REF_TRIPS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return } //dict contains all values of child "trips"
            let passengerUID = snapshot.key
            let trip = Trip(riderUID: passengerUID, dict: dictionary)
            completion(trip!)
            //print("DEBUG: trip info is \(trip)")
        }
        
    }
    
    func observeTripCanceled(trip: Trip, completion: @escaping() -> Void) {
        guard let riderUID = trip.passengerUid else { return }
        
        //we have "observeSingleEvent" since we just need to listen to 1 cancel
        REF_TRIPS.child(riderUID).observeSingleEvent(of: .childRemoved) { _ in
            print("DEBUG: listening to DB, \(riderUID) canceled")
            completion() //indicate that we have done observing the event (if it get removed, we can do something in HomeVC)
        }
    }
    
    func acceptTrip(trip: Trip, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }

        let values = ["driverUid": uid, "driverEmail": email, "state": TripState.accepted.rawValue] as [String : Any]
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uidPassenger = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uidPassenger).observe(.value) { snapshot in
            guard let dictionary = snapshot.value as? [String : Any] else { return }
            let passengerUID = snapshot.key
            let trip = Trip(riderUID: passengerUID, dict: dictionary)
            completion(trip!)
        }
    }
    
    func cancelRide(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uidRider = Auth.auth().currentUser?.uid else { return }
        
        REF_TRIPS.child(uidRider).removeValue(completionBlock: completion)
    }
    
    
    func updateDriverLocation(locationDriver: CLLocation) {
        guard let driverUID = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        geofire.setLocation(locationDriver, forKey: driverUID)
    }
    
}

