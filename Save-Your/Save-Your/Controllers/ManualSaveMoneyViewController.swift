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
    var currDefaultUserGoalID : String = ""
    var currGoalAmount : Double = 0.0
    var currTotalUserSaving : Double?
    var goalTarget : Double = 0.0
    var savingAmount : Double = 0.0
    var savingRemaining : Double = 0.0
    
    var picker = UIPickerView()
    var goalNames : [String] = [String]()
    var goalNameToID : [String: String] = [:]
    var goalSelected : String = ""
    var goalSelectedID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If screen tapped, dismiss picker
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
            self.currDefaultUserGoalID = goalId ?? ""
            self.database.getStateOfGoal(goalId: goalId!, callback: {(prevAmount) -> Void in
                self.currGoalAmount = prevAmount ?? 0.0
                self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                    self.goalTarget = target ?? 0.0
                })
            })
        })
        self.database.getUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, callback: {(totalSav) -> Void in
            self.currTotalUserSaving = totalSav
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
        
        // Get current amount towards selected goal
        self.database.getStateOfGoal(goalId: goalSelectedID, callback: {(prevAmount) -> Void in            self.currGoalAmount = prevAmount ?? 0.0
        })
        
        self.database.getTargetOfGoal(goalId: goalSelectedID, callback: {(targ) -> Void in            self.goalTarget = targ ?? 0
            
        })

        
        
        // Set label text
        categoryLabel.text = goalSelected
        
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "manualToAddBalance") {
            let viewController = segue.destination as! CompleteAndTransferController
            viewController.savingAmountRemaining = savingRemaining
            viewController.deletedGoalID = goalSelectedID
        } else if (segue.identifier == "newDefaultGoalSegue") {
            let viewController = segue.destination as! NewDefaultGoalController
            viewController.oldCurrGoalID = currDefaultUserGoalID
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Get value from amount field
        var trimAmount = amountTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.savingAmount = Double(trimAmount) ?? 0.0
        // If amount field is blank or negative, popup error and stay
        if (self.savingAmount == nil || self.savingAmount <= 0.0 ) {
            createErrorAlert(title: "Invalid savings amount entered!")
            return
        }
        
        // Update total lifetime user saving
        let newUserSavingTotal = currTotalUserSaving! + savingAmount
        // Add this amount to user's total savings
        self.database.updateUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, newAmount: newUserSavingTotal)
        
        
        // Verify saved amount doesn't complete a goal
        var totalWithSaving = savingAmount + currGoalAmount
        print("here\(totalWithSaving)")
        if totalWithSaving < self.goalTarget {
            // Normal transaction if target not reached
            self.logSaving(amount: savingAmount)
            // Go back to home screen
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        } else if totalWithSaving == self.goalTarget {
            // Log saving
            self.logSaving(amount: savingAmount)
            self.database.setGoalCompleted(goalID: goalSelectedID )
            // Delete goal and unwind to home
            createCompletionAlert()
           // createCompletionAlert(title: "Congratulations!  You reached your goal of '\(self.goalSelected)'!")
        } else {
            print("here")
            // Calculate amount remaining then proceed
            self.savingRemaining = savingAmount - (goalTarget - currGoalAmount)
            self.logSaving(amount: goalTarget - currGoalAmount)
            createExceedAlert()
        }
    }
    
    func createCompletionAlert() {
        let alert = UIAlertController(title: "Congratulations!  You reached your goal of '\(self.goalSelected)'!", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(action) in self.deleteGoalAndSegueToNewDefault(goalID: self.goalSelectedID)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createExceedAlert() {
        let alert = UIAlertController(title: "Congratulations!  You have exceeded your goal of '\(self.goalSelected)'!  Please allocate rest of saving to another goal", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(action) in self.deleteGoalAndSegueToSavingAllocation(goalID: self.goalSelectedID)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Deletes goal and segues to new default goal storyboard
    func deleteGoalAndSegueToNewDefault(goalID: String) {
        //        self.database.deleteGoal(goalID: goalID)
        print("deleting goal - not really right now")
        performSegue(withIdentifier: "newDefaultGoalSegueFromManual", sender: self)
    }
    
    // Deletes goal and segues to allocating extra savings
    func deleteGoalAndSegueToSavingAllocation(goalID: String) {
        //        self.database.deleteGoal(goalID: goalID)
        print("deleting goal - not really right now")
        performSegue(withIdentifier: "manualToAddBalance", sender: self)
    }
    
    
    // Handles logging a saving given the amount
    func logSaving(amount: Double) {
        // Create transaction
        var newTransaction = ManualEntryTransaction(category: "manual", userId: (Auth.auth().currentUser?.uid)!, amount: amount, goalId: self.goalSelectedID)
        // Add transaction to db
        var newTransactionId = self.database.addTransaction(transaction: newTransaction)
        // Add transaction to user
        self.database.addTransactionToUser(transactionId: newTransactionId!, userId: (Auth.auth().currentUser?.uid)!)
        // Add transaction to goal
        self.database.addTransactionToGoal(transactionId: newTransactionId!, goalId: self.goalSelectedID)
        // Update goal--> Get current state, perform operations, update
        let newGoalAmount = amount + currGoalAmount
        self.database.updateGoalAmountSaved(goalId: goalSelectedID, newAmount: newGoalAmount)
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
    
    func createExceedAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: {(action) in self.deleteGoalAndTransferBalance(goalID: self.goalSelectedID)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handles deletion of goal and unwinding to home
    func deleteGoalAndUnwind(goalID: String) {
//        self.database.deleteGoal(goalID: goalID)
        print("pretend to delete in unwind")
        // Designate new default goal if goal completed was default goal
        if goalID == currDefaultUserGoalID {
            performSegue(withIdentifier: "newDefaultGoalSegueFromManual", sender: self)
        } else {
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        }
    }
    
    // Handles deletion of goal and segue to transfer balance screen
    func deleteGoalAndTransferBalance(goalID: String) {
//        self.database.deleteGoal(goalID: goalID)
        print("pretend to delete in transfer")
        performSegue(withIdentifier: "manualToAddBalance", sender: self)
    }
    
    func createErrorAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    

}
