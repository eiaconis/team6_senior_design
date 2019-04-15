//
//  ManualSaveMoneyViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseUI

class ManualSaveMoneyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var categoryLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    var prevAmount : Double?
    var currTotal : Double?
    var goalTarget : Double = 0.0
    
    var picker = UIPickerView()
    var goalNames : [String] = [String]()
    var goalNameToID : [String: String] = [:]
    var goalSelected : String = ""
    var goalSelectedID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If screen tapped, dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Picker set up
        picker.delegate = self
        picker.dataSource = self
        categoryLabel.inputView = picker
        updatePickerView()
        populatePlaceholderText()
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Initialize state for saving to default/current goal
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: {(goalId) -> Void in
            self.database.getStateOfGoal(goalId: goalId!, callback: {(prev) -> Void in
                self.prevAmount = prev
                self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                    self.goalTarget = target ?? 0.0
                })
            })
        })
        self.database.getUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, callback: {(totalSav) -> Void in
            self.currTotal = totalSav
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return goalNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return goalNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        goalSelected = goalNames[row] as String
        goalSelectedID = goalNameToID[goalSelected]!
        print("goal selected = \(goalSelected) with id = \(goalSelectedID)")
        
        // Get current amount towards selected goal
        self.database.getStateOfGoal(goalId: goalSelectedID, callback: {(prev) -> Void in
            print("Previous amount saved towards goal = \(prev)")
            self.prevAmount = prev
        })
        
        
        // Set label text
        categoryLabel.text = goalSelected
        
        self.view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Get value from amount field
        var savingAmount = Double(amountTextField.text!)
        // If amount field is blank or negative, popup error and stay
        if (savingAmount == nil || savingAmount! <= 0.0 ) {
            print("savingAmount is /\(savingAmount)")
            createErrorAlert(title: "Invalid savings amount entered!")
            return
        }
        
        // Verify saved amount doesn't complete a goal
        var totalWithSaving = savingAmount! + self.prevAmount!
        if totalWithSaving < self.goalTarget {
            // Normal transaction if target not reached
            self.logSavingWithoutExceedingGoal(savingAmount: savingAmount!)
            // Go back to home screen
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        } else if totalWithSaving == self.goalTarget {
            // Log saving
            self.logSavingWithoutExceedingGoal(savingAmount: savingAmount!)
            // Delete goal and unwind to home
            createCompletionAlert(title: "Congratulations!  You reached your goal of '\(self.goalSelected)'!")
        } else {
            // Take to new screen and choose where remaining saving should go
            // Delete goal that was completed
        }
    }
    
    // Handles logging a saving when the amount saved does not cause the user to complete the goal
    func logSavingWithoutExceedingGoal(savingAmount: Double) {
        // Create transaction
        var newTransaction = ManualEntryTransaction(category: "manual", userId: (Auth.auth().currentUser?.uid)!, amount: savingAmount, goalId: self.goalSelectedID)
        var newUserSavingTotal = self.currTotal! + savingAmount
        let newGoalAmount = savingAmount + self.prevAmount!
        // Add transaction to db
        var newTransactionId = self.database.addTransaction(transaction: newTransaction)
        // Add transaction to user
        self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
        // Add transaction to goal
        self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.goalSelectedID)
        // Update goal--> Get current state, perform operations, update
        self.database.updateGoalAmountSaved(goalId: goalSelectedID, newAmount: newGoalAmount)
        // Add this amount to user's total savings
        self.database.updateUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, newAmount: newUserSavingTotal)
    }
    
    // Function to load picker view with goal names for user
    func updatePickerView() {
        let goalsClosure = {(returnedGoalIDs: [String]?) -> Void in
            let goalIDs = returnedGoalIDs ?? []
            for goalID in goalIDs {
                let goalNameClosure = { (goalName : String?) -> Void in
                    if goalName != nil {
                        self.goalNames.append(goalName!)
                        self.goalNameToID[goalName!] = goalID
                        self.picker.reloadAllComponents()
                    }
                }
                self.database.getStringGoalTitle(goalID: goalID, callback: goalNameClosure)
            }
        }
        self.database.getAllGoalsForUser(uid: (Auth.auth().currentUser?.uid)!, callback: goalsClosure)
    }
    
    /* Populates placeholder text in label to current user goal and "selects"
     current goal as default to save to
     */
    func populatePlaceholderText() {
        let placeholderClosure = {(goalID: String?) -> Void in
            self.goalSelectedID = goalID ?? ""
            let goalNameClosure = { (goalName : String?) -> Void in
                if goalName != nil {
                    print("Current goal is '\(goalName)'")
                    self.categoryLabel.placeholder = goalName
                    self.goalSelected = goalName ?? ""
                }
            }
            self.database.getStringGoalTitle(goalID: goalID!, callback: goalNameClosure)
        }
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: placeholderClosure)
    }
    
    func createCompletionAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(action) in self.deleteGoalAndUnwind(goalID: self.goalSelectedID)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handles deletion of goal and unwinding to home
    func deleteGoalAndUnwind(goalID: String) {
        self.database.deleteGoal(goalID: goalID)
        self.performSegue(withIdentifier: "unwindSegueToHome", sender: self)
    }
    
    func createErrorAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }

}
