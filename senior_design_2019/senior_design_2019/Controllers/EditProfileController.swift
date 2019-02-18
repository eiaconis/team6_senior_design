//
//  EditProfileController.swift
//  senior_design_2019
//
//  Created by OIDUser on 2/15/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit

class EditProfileController: UIViewController {
    
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
        // TODO: Fetch profile info and set placeholder text for each field
        emailField.placeholder = "email saved in database"
        passwordField.placeholder = "password saved in database"
        firstNameField.placeholder = "first name saved in database"
        lastNameField.placeholder = "last name saved in database"
        phoneField.placeholder = "phone saved in database"
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    
}
