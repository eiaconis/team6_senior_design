//
//  CompleteAndTransferController.swift
//  Save-Your
//
//  Created by OIDUser on 4/15/19.
//

import UIKit
import FirebaseAuth

class CompleteAndTransferController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Variables
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    var picker = UIPickerView()
    var goalNames : [String] = [String]()
    var goalNameToID : [String: String] = [:]
    var goalSelected : String = ""
    var goalSelectedID : String = ""
    var amountSavedTowardsGoal : Double = 0.0
    var savingAmountRemaining : Double = 0.0
    var goalTarget : Double = 0.0
    var totalUserSavings : Double = 0.0
    var currUserGoalID : String = ""
    
    var deletedGoalID : String = ""
    
    // Labels
    @IBOutlet weak var savingRemainingLabel: UILabel!
    
    // Fields
    @IBOutlet weak var goalField: UITextField!
    
    // Buttons
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If screen tapped, dismiss picker
        self.hideKeyboardWhenTappedAround()
        
        // Picker set up
        picker.delegate = self
        picker.dataSource = self
        goalField.inputView = picker
        updatePickerView()
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Update saving remaining label
        savingRemainingLabel.text = "Saving Remaining: $\(self.formatDouble(amount: savingAmountRemaining))"
        
        // Initialize state for saving to default/current goal
        self.database.getUserCurrGoal(uid: (Auth.auth().currentUser?.uid)!, callback: {(goalId) -> Void in
            self.currUserGoalID = goalId ?? ""
            self.database.getStateOfGoal(goalId: goalId!, callback: {(savedAmount) -> Void in
                self.amountSavedTowardsGoal = savedAmount ?? 0.0
                self.database.getTargetOfGoal(goalId: goalId!, callback: {(target) -> Void in
                    self.goalTarget = target ?? 0.0
                })
            })
        })
        self.database.getUserTotalSavings(uid: (Auth.auth().currentUser?.uid)!, callback: {(totalSav) -> Void in
            self.totalUserSavings = totalSav ?? 0.0
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "newDefaultGoalSegue") {
            let viewController = segue.destination as! NewDefaultGoalController
            viewController.oldCurrGoalID = currUserGoalID
        }
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
        self.database.getStateOfGoal(goalId: goalSelectedID, callback: {(savedAmount) -> Void in
            print("Previous amount saved towards goal = \(savedAmount)")
            self.amountSavedTowardsGoal = savedAmount ?? 0.0
        })
        
        // Set label text
        goalField.text = goalSelected
        
        self.view.endEditing(true)
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
                if goalID != self.deletedGoalID {
                    self.database.getStringGoalTitle(goalID: goalID, callback: goalNameClosure)
                }
            }
        }
        self.database.getAllGoalsForUser(uid: (Auth.auth().currentUser?.uid)!, callback: goalsClosure)
    }
    
    // Format double to two decimals
    func formatDouble(amount: Double) -> String {
        return String(format: "%.2f", round(100 * amount) / 100)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        self.logSaving(amount: savingAmountRemaining)
        if deletedGoalID == currUserGoalID {
            self.performSegue(withIdentifier: "newDefaultGoalSegue", sender: self)
        } else if (false) {
            // TODO: Check if saving completes new selected goal
        } else {
            self.performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        }
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
        let newGoalAmount = amount + amountSavedTowardsGoal
        self.database.updateGoalAmountSaved(goalId: goalSelectedID, newAmount: newGoalAmount)
    }
    
}
