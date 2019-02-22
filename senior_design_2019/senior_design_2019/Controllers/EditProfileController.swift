//
//  EditProfileController.swift
//  senior_design_2019
//
//  Created by OIDUser on 2/15/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditProfileController: UIViewController {
    
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    
    // Text Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    // Buttons
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch profile info and set placeholder text for each field
        self.database.getUserEmail(uid: (Auth.auth().currentUser?.uid)!, callback: {(email) -> Void in
            print("email in db = \(email)")
            self.emailField.placeholder = email
        })
        passwordField.placeholder = "******"
        self.database.getUserFirstName(uid: (Auth.auth().currentUser?.uid)!, callback: {(firstName) -> Void in
            self.firstNameField.placeholder = firstName
        })
        self.database.getUserLastName(uid: (Auth.auth().currentUser?.uid)!, callback: {(lastName) -> Void in
            self.lastNameField.placeholder = lastName
        })
        self.database.getUserPhone(uid: (Auth.auth().currentUser?.uid)!, callback: {(phone) -> Void in
            self.phoneField.placeholder = phone
        })
        phoneField.placeholder = "phone saved in database"
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    
}
