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
        print("creating user")
        Auth.auth().createUser(withEmail: newUser.email!, password: password) { user, error in
            print("created user \(String(describing: user)) with error \(String(describing: error))")
            // Handle error creating account
            if error != nil {
                print("error creating user \(error.debugDescription)")
                if view != nil {
                    // TODO: Handle error
                }
            } else if user != nil {
                // Add user to UserTable
                self.addUser(user: newUser, goal: goal, uid: (Auth.auth().currentUser?.uid)!)
            }
        }
    }
    
    // Login to an existing account with provided email and password
    // Input: email and password
    // Output: void. Success will be determined by page shown. 
    func login(email: String, password: String, view: UIViewController?){
        print("loging in: \(email) , \(password)")
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            // Handle error logging into account
            if error != nil {
                print("error logging in: \(error.debugDescription)")
                if view != nil {
                    print("error")
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
        print("logging out")
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
        print("login error")
        presentPopup(alert: alert, view: view, returnToLogin: false)
    }
    
    private func logoutError( view: UIViewController) {
        let alert = UIAlertController(title: "Logout Error",
                                      message: "Unknown logout error.",
                                      preferredStyle: .alert)
        print("logout error")
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
        print("adding user")
        // If user did not choose to intialize a goal, create default goal
        var newGoalId : String?
        if goal == nil {
            let defaultGoal = Goal(userId: uid, title: "First Time Saver", target: 100.00)
            newGoalId = self.addGoal(goal: defaultGoal)
        } else {
            newGoalId = goal!.goalId
        }
        let newUser : Any = [ "uid" : uid,
                              "formattedEmail": user.formattedEmail!,
                              "firstName": user.firstName!,
                              "lastName": user.lastName!,
                              "phoneNumber": user.phoneNumber!,
                              "currentGoal": newGoalId!,
                              "totalSavings": 0
        ]
        self.ref.child("UserTable/\(uid)").setValue(newUser)
    }
    
    func getUserCurrGoal(uid: String, callback : @escaping (String?) -> Void) {
        //        if let currUID = Auth.auth().currentUser?.uid {
        //            print("DB: \(currUid)")
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
    func getUserFirstName(uid: String, callback : @escaping (String?) -> Void) {
        self.ref.child("UserTable/\(uid)/firstName").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let firstName = snapshot.value as? String
                callback(firstName!)
            } else {
                callback(nil)
            }
        })
    }
    
    // Get user's current last name
    func getUserLastName(uid: String, callback : @escaping (String?) -> Void) {
        self.ref.child("UserTable/\(uid)/lastName").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let lastName = snapshot.value as? String
                callback(lastName!)
            } else {
                callback(nil)
            }
        })
    }
    
    // Get user's current phone number
    func getUserPhone(uid: String, callback : @escaping (String?) -> Void) {
        self.ref.child("UserTable/\(uid)/phoneNumber").observe(.value, with: { (snapshot) in
            if snapshot.exists(){
                let phoneNumber = snapshot.value as? String
                callback(phoneNumber!)
            } else {
                callback(nil)
            }
        })
    }
    
    // Set user email
    func setUserEmail(uid: String, email: String) {
        let formattedEmail = reformatEmail(email: email)
        self.ref.child("UserTable/\(uid)/formattedEmail/").setValue(formattedEmail)
    }
    
    // Set user first name
    func setUserFirstName(uid: String, firstName: String) {
        self.ref.child("UserTable/\(uid)/firstName/").setValue(firstName)
    }
    
    // Set user last name
    func setUserLastName(uid: String, lastName: String) {
        self.ref.child("UserTable/\(uid)/lastName/").setValue(lastName)
    }
    
    // Set user phone number
    func setUserPhoneNumber(uid: String, phone: String) {
        self.ref.child("UserTable/\(uid)/phoneNumber/").setValue(phone)
    }
    
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
        // Update in UserTable
        let newFormatEmail = reformatEmail(email: newEmail)
        let userId = Auth.auth().currentUser?.uid
        self.ref.child("UserTable/\(String(describing: userId))/formattedEmail").setValue(newFormatEmail)
    }
    
    // Edit password
    func editPassword(newPassword: String) {
        Auth.auth().currentUser?.updatePassword(to: newPassword)
    }
    
    
    // Edit currently signed in user's phone
    // Input: String new phone
    // Output: ??
    func editPhone(newPhone: String) {
        // Update in UserTable
        let userId = Auth.auth().currentUser?.uid
        self.ref.child("UserTable/\(String(describing: userId))/phoneNumber").setValue(newPhone)
    }
    
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
        print("adding goal")
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
        print("adding goal to user")
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
                print("No Goals found for user with id \(uid)")
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
                    print("Goal Name not found for goal ID \(goalID)")
                    callback(nil)
                }
            }
        })
    }
    
    // TODO: Transfer balance of goal 1 to goal 2
    
    // TODO: Delete goal
    
    //----------------------- Transaction Methods----------------------------------------
    // Puts transaction item in TransactionTable
    // Input: Transaction
    // Output: String, transaction's unique identifier
    func addTransaction(transaction: Transaction)-> String? {
        print("adding transaction")
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
        print("adding transaction to user")
        self.ref.child("UserTable/\(userId)/transactions/\(transactionId)").setValue(true)
        return
    }
    
    // Puts transaction item in goal's list of transactions
    // Input: String transactionId, String goalId
    // Output: ???
    func addTransactionToGoal(transactionId: String, goalId: String) -> Void {
        print("adding transaction to goal")
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
        print("Current time stamp = \(timeStamp)")
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
