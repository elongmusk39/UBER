//
//  User.swift
//  UBER
//
//  Created by Long Nguyen on 4/19/21.
//

import UIKit

struct User {
    let email: String
    let fullname: String
    let accountType: String
    let pass: String
    
    //we create the "dictionary" to store all fetched data
    init(dictionary: [String: Any]) {
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? String ?? ""
        self.pass = dictionary["password"] as? String ?? ""
    }
}
