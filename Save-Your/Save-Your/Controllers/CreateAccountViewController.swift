//
//  CreateAccountViewController.swift
//  spend_to_save
//
//  Created by Elena Iaconis on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    // Database Instance
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    
    @IBOutlet weak var continueButton: UIButton!
    
    // Text Fields
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Pad and round the 'Continue' Button
        continueButton.layer.cornerRadius = 5
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let phone = phoneNumberTextField.text ?? ""
        if email == "" {
            createAlert(title: "Email required")
        } else if password == "" {
            createAlert(title: "Password required")
        } else if firstName == "" {
            createAlert(title: "First name required")
        } else if lastName == "" {
            createAlert(title: "Last name required")
        } else if phone == "" {
            createAlert(title: "Phone number required")
        } else {
            let newUser = User(email: email, firstName: firstName, lastName: lastName, phoneNumber: phone)
            database.createAccount(newUser: newUser, goal: nil, password: password, view: self)
        }
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // If view tapped, dismiss keyboard
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}

