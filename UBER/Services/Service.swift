//
//  Service.swift
//  UBER
//
//  Created by Long Nguyen on 4/19/21.
//

import UIKit
import Firebase
import CoreLocation //from external module

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service {
    
    static let shared = Service()
    let currentUid = Auth.auth().currentUser?.uid ?? "no uid"
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
    
    func fetchUserData(completion: @escaping(User) -> Void) {
        print("DEBUG: fetching data user \(currentEmail)..")
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return } //put all user's info into the dictionary
            let userFetched = User(dictionary: dict)
            completion(userFetched)
        }
    }
    
}
