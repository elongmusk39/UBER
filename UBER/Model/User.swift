//
//  User.swift
//  UBER
//
//  Created by Long Nguyen on 4/19/21.
//

import UIKit
import CoreLocation

enum AccountType: Int {
    case passenger
    case driver
}

struct User {
    let email: String
    let fullname: String
    var accountType: AccountType!
    let pass: String
    var location: CLLocation?
    let uid: String
    
    
    //we create the "dictionary" to store all fetched data
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.pass = dictionary["password"] as? String ?? ""
        
        if let index = dictionary["accountType"] as? Int {
            self.accountType = AccountType(rawValue: index)
        }
    }
}
