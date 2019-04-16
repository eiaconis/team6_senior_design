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
    func createAccount(newUser: User, goal: Goal?, password: String, view: UIViewController?) {
        Auth.auth().createUser(withEmail: newUser.email!, password: password) { user, error in
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = "\(newUser.firstName!)|\(newUser.lastName!)"
            changeRequest?.commitChanges { (error) in
                // TODO: handle
            }
            // Handle error creating account
            if error != nil {
                print("error creating user \(error.debugDescription)")
                if view != nil {
                    // TODO: Handle error
                }
            } else if user != nil {
                // Add user to UserTable
                self.addUser(user: newUser, goal: goal, uid: (Auth.auth().currentUser?.uid)!)
                view?.performSegue(withIdentifier: "segue_to_add_goal", sender: view!)
            }
        }
    }
    
    // Login to an existing account with provided email and password
    // Input: email and password
    // Output: void. Success will be determined by page shown. 
    func login(email: String, password: String, view: UIViewController?){
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            // Handle error logging into account
            if error != nil {
                print("error logging in: \(error.debugDescription)")
                if view != nil {
                    self.loginError(error: error!, view: view!)
                }
            } else if user != nil {
                if view != nil {
                    //OK login, show account homepage
                        if view != nil {
                            view?.performSegue(withIdentifier: "log_in", sender: view!)
                        }
                }
            }
        }
    }
    
    // Logout of currently logged in account
    // Output: void. Success will be determined by page shown.
    func logout(view: UIViewController?){
        do {
            try Auth.auth().signOut()
        } catch {
            self.logoutError(view: view!)
        }
    }
    
    private func loginError(error: Error, view: UIViewController) {
        let alert = UIAlertController(title: "Login Error",
                                      message: error.localizedDescription ,
                                      preferredStyle: .alert)
        presentPopup(alert: alert, view: view, returnToLogin: false)
    }
    
    private func logoutError( view: UIViewController) {
        let alert = UIAlertController(title: "Logout Error",
                                      message: "Unknown logout error.",
                                      preferredStyle: .alert)
        presentPopup(alert: alert, view: view, returnToLogin: false)
    }
    
    private func presentPopup(alert: UIAlertController, view: UIViewController, returnToLogin: Bool) {
        
        let returnAction = UIAlertAction(title:"Login Again",
                                         style: .default,
                                         handler:  { action in view.performSegue(withIdentifier: "loginErrorSegue", sender: self) })
        
        let continueAction = UIAlertAction(title: "Continue",
                                           style: .default)
        
        alert.addAction(returnToLogin ? returnAction : continueAction)
        view.present(alert, animated: true, completion: nil)
    }
    
    // Puts user item in UserTable for user generated information and details
    // Input: User and unique identifier generated by account creation in authentication step.
    // Output: ???
    func addUser(user: User, goal: Goal?, uid: String)-> Void {
        // If user did not choose to intialize a goal, create default goal
        //var newGoalId : String? = goal!.goalId
        let newUser : Any = [ "uid" : uid,
                              "totalSavings": 0
        ]
        self.ref.child("UserTable/\(uid)").setValue(newUser)
    }
    
    func getUserCurrGoal(uid: String, callback : @escaping (String?) -> Void) {
        self.ref.child("UserTable/\(uid)/currentGoal").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let currGoalId = snapshot.value as? String
                callback(currGoalId!)
            } else {
                callback(nil)
            }
        })
        //        }
    }
    
    // Get user's current first name
    func getUserFirstName() -> String? {
        var fullNameArr  = (Auth.auth().currentUser?.displayName)!.characters.split{$0 == "|"}.map(String.init)
        return fullNameArr[0]
    }
    
    // Get user's current last name
    func getUserLastName() -> String {
        var fullName = (Auth.auth().currentUser?.displayName)!
        var fullNameArr  = (Auth.auth().currentUser?.displayName)!.characters.split{$0 == "|"}.map(String.init)
        return fullNameArr[1]
    }
    
    // DEPRECATED
//    // Get user's current phone number
//    func getUserPhone(uid: String, callback : @escaping (String?) -> Void) {
//        self.ref.child("UserTable/\(uid)/phoneNumber").observe(.value, with: { (snapshot) in
//            if snapshot.exists(){
//                let phoneNumber = snapshot.value as? String
//                callback(phoneNumber!)
//            } else {
//                callback(nil)
//            }
//        })
//    }
    
    // Set user email
    func setUserEmail(uid: String, email: String) {
        Auth.auth().currentUser?.updateEmail(to: email)
    }
    
    // Set user first name
    func setUserFirstName(uid: String, firstName: String) {
        var oldLastName = getUserLastName()
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "\(firstName)|\(oldLastName)"
        changeRequest?.commitChanges { (error) in
            // TODO: handle
        }
    }
    
    // Set user last name
    func setUserLastName(uid: String, lastName: String) {
        var oldFirstName = getUserFirstName()
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "\(oldFirstName)|\(lastName)"
        changeRequest?.commitChanges { (error) in
            // TODO: handle
        }
    }
    
    // DEPRECATED
//    // Set user phone number
//    func setUserPhoneNumber(uid: String, phone: String) {
//        self.ref.child("UserTable/\(uid)/phoneNumber/").setValue(phone)
//    }
    
    // Edit currently set goal in user account
    // Input: String userId, String goalId
    // Output:
    func editGoalInUser(userId: String, goalId: String) {
        self.ref.child("UserTable/\(userId)/currentGoal/").setValue(goalId)
    }
    
    // Edit currently signed in user's email
    // Input: String new email
    // Output: ??
    func editEmail(newEmail: String) {
        // Update in authentication
        Auth.auth().currentUser?.updateEmail(to: newEmail) { (error) in
            // TODO: Error handle
        }
    }
    
    // Edit password
    func editPassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword)
    }
    
    // DEPRECATED
//    // Edit currently signed in user's phone
//    // Input: String new phone
//    // Output: ??
//    func editPhone(newPhone: String) {
//        // Update in UserTable
//        let userId = Auth.auth().currentUser?.uid
//        self.ref.child("UserTable/\(String(describing: userId))/phoneNumber").setValue(newPhone)
//    }
    
    func getUserTotalSavings(uid: String, callback : @escaping (Double?) -> Void) {
        self.ref.child("UserTable/\(uid)/totalSavings").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let totalSav = snapshot.value as? Double
                callback(totalSav)
            } else {
                callback(nil)
            }
        })
    }
    
    func updateUserTotalSavings(uid: String, newAmount: Double) {
        self.ref.child("UserTable/\(uid)/totalSavings").setValue(newAmount)
    }
    
    //----------------------- Goal Methods----------------------------------------
    
    // Puts goal item in GoalTable
    // Input: Goal
    // Output: String goalId of newly created goal
    func addGoal(goal: Goal)-> String{
        let newGoal : Any = [ "userId" : goal.userId!,
                              "title" : goal.title!,
                              "target" : goal.target ?? 100.00,
                              "amountSaved": 0,
                              "deadline": goal.deadline ?? nil,
                              ]
        let goalId = self.ref.child("GoalTable").childByAutoId().key
        goal.setGoalId(id: goalId!)
        self.ref.child("GoalTable/\(goalId!)").setValue(newGoal)
        return goalId!
    }
    
    
    // Puts goal identifier in user's list of goals
    // Input: String goalId, String userId
    // Output: ???
    func addGoalToUser(goalId: String, userId: String) -> Void {
        self.ref.child("UserTable/\(userId)/goals/\(goalId)").setValue(true)
        return
    }
    
    // Update state of goal after transaction
    // Input: String goalId, Double new current amount saved
    func updateGoalAmountSaved(goalId: String, newAmount: Double) -> Void{
        self.ref.child("GoalTable/\(goalId)/amountSaved").setValue(newAmount)
    }
    
    /* Gets current state of goal
     Input: String goalId, callback function
     Output: ???
     */
    func getStateOfGoal(goalId: String, callback : @escaping (Double?) -> Void) {
       
        //        if let currUID = Auth.auth().currentUser?.uid {
        //            print("DB: \(currUid)")
        self.ref.child("GoalTable/\(goalId)/amountSaved").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let currAmount = snapshot.value as? Double
                callback(currAmount!)
            } else {
                callback(nil)
            }
        })
        //        }
    }
    
    /* Gets current state of goal
     Input: String goalId, callback function
     Output: ???
     */
    func getTargetOfGoal(goalId: String, callback : @escaping (Double?) -> Void) {
        //        if let currUID = Auth.auth().currentUser?.uid {
        //            print("DB: \(currUid)")
        self.ref.child("GoalTable/\(goalId)/target").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let currTarget = snapshot.value as? Double
                callback(currTarget!)
            } else {
                callback(nil)
            }
        })
        //        }
    }
    
    /* Gets titles of all goals associated with a user
     Input: N/A
     Output: String array of goal IDs
     */
    func getAllGoalsForUser(uid: String, callback : @escaping ([String]?) -> Void) {
        self.ref.child("UserTable/\(uid)/goals").observe(.value, with : {(snapshot) in
            if snapshot.exists() {
                let goalIDs = snapshot.value as? NSDictionary
                if let goalIDstr = goalIDs?.allKeys as? [String]? {
                    callback(goalIDstr)
                }
            } else {
                callback(nil)
            }
        })
    }
    
    /*
     Function to get a goal's title from its goalID
     Input: String goal ID
     Output: String goal name escaping via callback
     */
    func getStringGoalTitle(goalID: String, callback: @escaping (String?) -> Void) {
        self.ref.child("GoalTable/\(goalID)/title").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                if let title = snapshot.value as? String {
                    let goalTitle : String = title
                    callback(goalTitle)
                } else {
                    callback(nil)
                }
            }
        })
    }
    
    /*
     Function to get a menu
     */
    func getMenu(callback: @escaping (NSDictionary) -> Void) {
        self.ref.child("MenuTable/Starbucks").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                if snapshot.exists() {
                    callback((snapshot.value as? NSDictionary)!)
                } else {
                    callback([:])
                }
            }
        })
    }

    // Get deadline of a goal given the goal ID
    func getGoalDeadline(goalID: String, callback: @escaping (String?) -> Void) {
        self.ref.child("GoalTable/\(goalID)/deadline").observe(.value, with: {(snapshot) in
            if snapshot.exists() {
                if let deadline = snapshot.value as? String {
                    callback(deadline)
                } else {
                    callback(nil)
                }
            }
        })
    }
    
    // Check goal is completed
    func checkGoalCompleted(goalID: String, callback: @escaping (Bool) -> Void) {
        self.ref.child("GoalTable/\(goalID)/completed").observe(.value, with: {(snapshot) in
            if snapshot.exists() {
                callback(true)
            } else {
                callback(false)
            }
        })
    }
    
    // Set new target for a goal given the goal ID and new amount
    func setGoalTarget(goalID: String, newAmount: Double) {
        self.ref.child("GoalTable/\(goalID)/target").setValue(newAmount)
    }
    
    // Set new deadline for a goal given the goal ID and new deadline
    func setGoalDeadline(goalID: String, newDeadline: String) {
        self.ref.child("GoalTable/\(goalID)/deadline").setValue(newDeadline)
    }
    
    // Mark goal as completed
    func setGoalCompleted(goalID: String) {
        self.ref.child("GoalTable/\(goalID)/completed").setValue(true)
    }
    
    // TODO: Transfer balance of goal 1 to goal 2
    
    // Delete goal
    func deleteGoal(goalID: String) {
        self.ref.child("GoalTable/\(goalID)").removeValue()
        self.ref.child("UserTable/\((Auth.auth().currentUser?.uid)!)/goals/\(goalID)").removeValue()
    }
    
    //----------------------- Transaction Methods----------------------------------------
    // Puts transaction item in TransactionTable
    // Input: Transaction
    // Output: String, transaction's unique identifier
    func addTransaction(transaction: Transaction)-> String? {
        var newTransaction : Any = []
        if transaction.isManualEntryTransaction() {
            newTransaction = [ "userId" : transaction.userId!,
                               "amount": transaction.amount!,
                               "goalId": transaction.goalId!,
                               "timestamp": self.getTimestampAsString(),
                               "category": transaction.getCategory()!
                ] as [String : Any]
        } else {
            newTransaction = [ "userId" : transaction.userId!,
                               "amount": transaction.amount!,
                               "goalId": transaction.goalId!,
                               "timestamp": self.getTimestampAsString(),
                               "itemPurchased" : transaction.getItemPurchased()!,
                               "priceItemPurchased" : transaction.getPriceItemPurchased()!,
                               "itemDesired" : transaction.getItemDesired()!,
                               "priceItemDesired" : transaction.getPriceItemDesired()!,
                               "perceivedAmount" : transaction.getPricePerceived()!,
            ]as [String : Any]
        }
        
        let transactionId = self.ref.child("TransactionTable").childByAutoId().key
        transaction.setTransactionId(id: transactionId!)
        self.ref.child("TransactionTable/\(transactionId!)").setValue(newTransaction)
        return transactionId
    }
    
    // Puts transaction item in user's list of transactions
    // Input: String transactionId, String userId
    // Output: ???
    func addTransactionToUser(transactionId: String, userId: String) -> Void{
        self.ref.child("UserTable/\(userId)/transactions/\(transactionId)").setValue(true)
        return
    }
    
    // Puts transaction item in goal's list of transactions
    // Input: String transactionId, String goalId
    // Output: ???
    func addTransactionToGoal(transactionId: String, goalId: String) -> Void {
        self.ref.child("GoalTable/\(goalId)/transactions/\(transactionId)").setValue(true)
        return
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
        return timeStamp
    }
    
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
                reformattedEmail.append("^")
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
    
    // Retrieves original email
    func unformatEmail(email: String) -> String {
        let andSign : Character = "&"
        let star : Character = "*"
        let carrot : Character = "^"
        let lessThan : Character = "<"
        let greaterThan : Character = ">"
        
        var reformattedEmail : String = ""
        for char in email {
            if char == andSign {
                reformattedEmail.append(".")
            } else if char == star {
                reformattedEmail.append("#")
            } else if char == carrot {
                reformattedEmail.append("$")
            } else if char == lessThan {
                reformattedEmail.append("[")
            } else if char == greaterThan {
                reformattedEmail.append("]")
            } else {
                reformattedEmail.append(char)
            }
        }
        return reformattedEmail
    }
    
}
