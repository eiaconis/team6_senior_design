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
    var firstName: String?
    var lastName: String?
    var goals: [String]? // Array of unique goal identifiers associated with this account
    var currentGoal: String?
    var transactions: [String]? // Array of all unique transaction identifiers associated with this account
    var totalSavings: NSNumber?
    
    
    init(email: String, firstName: String, lastName: String) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // Sets user id to unique identifier created when it is added to database
    func setUid(id: String) {
        if uid == nil {
            self.uid = id
        }
    }
    
    //----------------------- Helper Methods ----------------------------------------
    /*
     Firebase does not allow querying in the database with the following characters: # $ [ or ]
     The following mapping resolves this:
     . --> &
     # --> *
     $ --> @
     [ --> <
     ] --> >
     */
    func reformatEmail(email: String) -> String {
        let period : Character = "."
        let pound : Character = "#"
        let dollar : Character = "$"
        let lBracket : Character = "["
        let rBracket : Character = "]"
        var reformattedEmail : String = ""
        for char in email {
            if char == period {
                reformattedEmail.append("&")
            } else if char == pound {
                reformattedEmail.append("*")
            } else if char == dollar {
                reformattedEmail.append("@")
            } else if char == lBracket {
                reformattedEmail.append("<")
            } else if char == rBracket {
                reformattedEmail.append(">")
            } else {
                reformattedEmail.append(char)
            }
        }
        return reformattedEmail 
    }
}
