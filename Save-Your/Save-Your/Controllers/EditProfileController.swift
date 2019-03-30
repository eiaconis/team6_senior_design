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
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if passwordField.text != nil && passwordField.text != "" && passwordField.text != "******" {
            print("detected password change")
            let newPass : String = passwordField.text!
            if (newPass.count > 5) {
                self.database.editPassword(newPassword: newPass)
                updatePlaceholderText()
            } else {
                createAlert(title: "Passwords must be at least 6 characters!")
                updatePlaceholderText()
                return
            }

        }
        if emailField.text != emailField.placeholder && emailField.text != "" {
            print(emailField.text)
            self.database.setUserEmail(uid: (Auth.auth().currentUser?.uid)!, email: emailField.text!)
        }
        if firstNameField.text != firstNameField.placeholder && firstNameField.text != ""{
            self.database.setUserFirstName(uid: (Auth.auth().currentUser?.uid)!, firstName: firstNameField.text!)
        }
        if lastNameField.text != lastNameField.placeholder && lastNameField.text != ""{
            self.database.setUserLastName(uid: (Auth.auth().currentUser?.uid)!, lastName: lastNameField.text!)
        }
        if phoneField.text != phoneField.placeholder && phoneField.text != ""{
            self.database.setUserPhoneNumber(uid: (Auth.auth().currentUser?.uid)!, phone: phoneField.text!)
        }
        
        // Display alert
        createAlert(title: "Profile information updated!")
        
        // Update placeholder text with new information
        updatePlaceholderText()
    }
    
    func updatePlaceholderText() {
        self.emailField.placeholder = Auth.auth().currentUser?.email
        self.passwordField.placeholder = "******"
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
