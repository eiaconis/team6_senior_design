//
//  DatabaseAccess.swift - Class to handle all interactions with Firebase tables
//  This includes capabilities for getting, setting, deleting, and changing values.
//  senior_design_2019
//
//  Created by Elena Iaconis on 1/28/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

import Firebase
import FirebaseDatabase
import FirebaseUI

/*
    Class to contain all database calls to retrieve, update, or add data to the database. Implemented as
    a singleton throughout application.
 */

class DatabaseAccess {
    
    static var instance: DatabaseAccess? = nil
    
    var ref: DatabaseReference!
    var error_logging_in: Error? = nil
    
    // Initializes database
    private init(){
        FirebaseApp.configure()
        ref = Database.database().reference()
    }
    
    // Gets instance of data base
    public static func getInstance() -> DatabaseAccess {
        if instance == nil { 
            instance = DatabaseAccess()
        }
        return instance!
    }
    
    deinit {
        do {
            try Auth.auth().signOut()
        } catch {
            
        }
    }
    
    //----------------------- Account Methods----------------------------------------
    // Create authenticated account in Firebase
    func authenticateAccount(email: String, password: String, view: UIViewController?) {
        print("creating user")
        Auth.auth().createUser(withEmail: email, password: password)
    }
    
    // TODO: Create a new user model with provided email, password, and phone number
    func createAccount(email: String, password: String, phoneNumber: String, view: UIViewController?){
        print("creating user")
        Auth.auth().createUser(withEmail: email, password: password)
//        { user, error in
//            print("created user \(user) with error \(error)")
//            // Handle error creating account
//            if error != nil {
//                print("error creating user \(error.debugDescription)")
//                if view != nil {
//                    //TODO:
//                   // self.createAccountError(error: error!, view: view!)
//                }
//            } else if user != nil {
//                // Create user model for new user
//                //TODO:
//                //self.createUserModelForCurrentUser()
//                if view != nil {
//                    //TODO:
//                   // self.okAccountCreation(view: view!)
//                }
//            }
//        }
    }
    
    // TODO: Login to an existing account with provided email and password
    func login(email: String, password: String, view: UIViewController?){
        print("loging in: \(email) , \(password)")
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            // Handle error logging into account
            if error != nil {
                print("error logging in: \(error.debugDescription)")
                if view != nil {
                    //TODO:
                  //  self.loginError(error: error!, view: view!)
                }
            } else if user != nil {
                if view != nil {
                    //TODO: OK login, show accounth homepage
                    view?.performSegue(withIdentifier: "log_in", sender: view!)
                }
            }
        }
    }
    
    // TODO: Edit password
    
    // TODO: Edit account phone number
    
    // TODO: Error handler for invalid login
    
    // TODO: Error handler for invalid account creation

 
    //----------------------- Goal Methods----------------------------------------
    // TODO: Add goal to currently logged in account
    
    // TODO: Add saving to associated goal
    
    // TODO: Get current state of goal
    
    // TODO: Transfer balance of goal 1 to goal 2
    
    // TODO: Delete goal
    

}
