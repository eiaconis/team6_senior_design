//
//  ViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 11/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Test adding goal
//         var testGoal = Goal(userId: "test", title: "test", target: 100.00)
//         database.addGoal(goal: testGoal)
        // Test getting goal's value
//        self.database.getStateOfGoal(goalId: "-LXoYEgmrwnhQifxEOAj", callback: {(amount) -> Void in
//            print("got goal amount")
//            print(amount)
//        })
        // Test adding transaction to goal
        //self.database.addTransactionToGoal(transactionId:"fake", goalId: "-LXoYEgmrwnhQifxEOAj")
        // Test creating user
         //let newUser = User(email: "eiaconis@email.com", firstName: "elena", lastName: "Iaconis", phoneNumber: "3826603")
        //database.createAccount(newUser: newUser, goal: nil, password: "test4443", view: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        database.login(email: emailTextField.text!, password: passwordTextField.text!, view: self)
    }
    
    // If view tapped, dismiss keyboard
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // Denote anchor for unwinding to upon logout
    @IBAction func unwindToLogout(segue:UIStoryboardSegue) { }
    

}

