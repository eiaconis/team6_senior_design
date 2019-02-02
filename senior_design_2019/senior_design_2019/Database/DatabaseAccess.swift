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
    
    // Create a new authenticated account and add user to UserTable
    // Input: Email and password for a new user
    // Output: TODO
    func createAccount(newUser: User, password: String, view: UIViewController?) {
        print("creating user")
        Auth.auth().createUser(withEmail: newUser.email!, password: password) { user, error in
            print("created user \(user) with error \(error)")
            // Handle error creating account
            if error != nil {
                print("error creating user \(error.debugDescription)")
                if view != nil {
                    // TODO: Handle error
                }
            } else if user != nil {
                // Add user to UserTable
                self.addUser(user: newUser, uid: (Auth.auth().currentUser?.uid)!)
            }
        }
    }
    
    // TODO: Login to an existing account with provided email and password
    // Input: email and password
    // Output: void. Success will be determined by page shown. 
    func login(email: String, password: String, view: UIViewController?){
        print("loging in: \(email) , \(password)")
        //TODO
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            // Handle error logging into account
            if error != nil {
                print("error logging in: \(error.debugDescription)")
                if view != nil {
                    print("error")
                    //TODO: Do NOT perform segue. Popup error.
                }
            } else if user != nil {
                if view != nil {
                    //OK login, show account homepage
                    //TODO: Perform segue
                    
                }
            }
        }
    }
    
    // Puts user item in UserTable for user generated information and details
    // Input: User and unique identifier generated by account creation in authentication step.
    // Output: ReturnValue<Bool>, true if executed correctly
    func addUser(user: User, uid: String)-> ReturnValue<Bool> {
        print("adding user")
        let newUser : Any = [ "uid" : uid,
                              "formattedEmail": user.formattedEmail,
                              "firstName": user.firstName,
                              "lastName": user.lastName,
                              "phoneNumber": user.phoneNumber
                              ]
        self.ref.child("UserTable/\(uid)").setValue(newUser)
        return ExpectedExecution()
    }
    
    // TODO: Edit password
    
    // TODO: Edit account phone number
    
    // TODO: Error handler for invalid login
    
    // TODO: Error handler for invalid account creation

 
    //----------------------- Goal Methods----------------------------------------
    // TODO: Add goal to currently logged in account
    
    // TODO: Add saving to associated goal
    
    // Puts goal item in GoalTable
    // Input: Goal
    // Output: ReturnValue<Bool>, true if executed correctly
    func addGoal(goal: Goal)-> ReturnValue<Bool> {
        print("adding goal")
        let newGoal : Any = [ "userId" : goal.userId,
                            "title" : goal.title,
                            "target" : goal.target,
        ]
        let goalId = self.ref.child("GoalTable").childByAutoId().key
        goal.setGoalId(id: goalId!)
        self.ref.child("GoalTable/\(goalId!)").setValue(newGoal)
        return ExpectedExecution()
    }
    
    // Puts goal identifier in user's list of goals
    // Input: String goalId, String userId
    // Output: ???
    func addGoalToUser(goalId: String, userId: String) {
        print("adding goal to user")
        self.ref.child("UserTable/\(userId)/goals/\(goalId)").setValue(true)
    }
    
    // TODO: Get current state of goal
    
    // TODO: Transfer balance of goal 1 to goal 2
    
    // TODO: Delete goal
    
    //----------------------- Transaction Methods----------------------------------------
    // Puts transaction item in TransactionTable
    // Input: Transaction
    // Output: String, transaction's unique identifier
    func addTransaction(transaction: Transaction)-> String? {
        print("adding transaction")
        let newTransaction : Any = [ "userId" : transaction.userId,
                                     "amount": transaction.amount,
                                     "category": transaction.category,
                                     "goalId": transaction.goalId,
                                     "timestamp": self.getTimestampAsString()
                              ]
        let transactionId = self.ref.child("TransactionTable").childByAutoId().key
        transaction.setTransactionId(id: transactionId!)
        self.ref.child("TransactionTable/\(transactionId!)").setValue(newTransaction)
        return transactionId
    }
    
    // Puts transaction item in user's list of transactions
    // Input: String transactionId, String userId
    // Output: ???
    func addTransactionToUser(transactionId: String, userId: String) {
        print("adding transaction to user")
        self.ref.child("UserTable/\(userId)/transactions/\(transactionId)").setValue(true)
    }
    
    // Puts transaction item in goal's list of transactions
    // Input: String transactionId, String goalId
    // Output: ???
    func addTransactionToGoal(transactionId: String, goalId: String) {
        print("adding transaction to goal")
        self.ref.child("GoalTable/\(goalId)/transactions/\(transactionId)").setValue(true)
    }
    
    
    //----------------------- Helper Methods ----------------------------------------
    /*
     Gets the current time stamp and returns it as a string
     Input: N/A
     Output: String representation of timestamp
     */
    func getTimestampAsString() -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timeStamp = formatter.string(from: Date())
        print("Current time stamp = \(timeStamp)")
        return timeStamp
    }
    

}
