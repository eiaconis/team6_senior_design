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
        updatePlaceholderText()
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // TODO: Save new user information - Doesn't update in DB currently
        // TODO: Add for password field. Not currently saving passwords
        if emailField.text != emailField.placeholder {
            self.database.setUserEmail(uid: (Auth.auth().currentUser?.uid)!, email: emailField.text!)
        } else if firstNameField.text != firstNameField.placeholder {
            self.database.setUserFirstName(uid: (Auth.auth().currentUser?.uid)!, firstName: firstNameField.text!)
        } else if lastNameField.text != lastNameField.placeholder {
            self.database.setUserLastName(uid: (Auth.auth().currentUser?.uid)!, lastName: lastNameField.text!)
        } else if phoneField.text != phoneField.placeholder {
            self.database.setUserPhoneNumber(uid: (Auth.auth().currentUser?.uid)!, phone: phoneField.text!)
        }
        
        // Display alert
        createAlert(title: "Profile information updated!")
        
        // Update placeholder text with new information
        updatePlaceholderText()
    }
    
    func updatePlaceholderText() {
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
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
