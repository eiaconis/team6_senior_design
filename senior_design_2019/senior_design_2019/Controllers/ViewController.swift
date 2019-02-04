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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
         let newUser = User(email: "testingLots5558@email.com", firstName: "elena", lastName: "Iaconis", phoneNumber: "3333333")
        database.createAccount(newUser: newUser, goal: nil, password: "test4443", view: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        database.login(email: emailTextField.text!, password: passwordTextField.text!, view: self)
    }
    

}

