//
//  User.swift
//  senior_design_2019
//
//  Created by Elena Iaconis on 1/30/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import Foundation

class User {
    
    var uid: String?
    var email: String?
    var formattedEmail: String? // Must reformat to store in Firebase
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var goals: [String] // Array of unique goal identifiers
    
    
    init(uid: String, email: String, formattedEmail: String, firstName: String, lastName: String, phoneNumber: String, goals: [String]) {
        self.uid = uid
        self.email = email
        self.formattedEmail = formattedEmail
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.goals = goals
    }
    
}
