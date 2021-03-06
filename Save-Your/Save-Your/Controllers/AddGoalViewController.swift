//
//  AddGoalViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 1/25/19.
//  Copyright © 2019 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AddGoalViewController: UIViewController {

    // Database Instance
    let database: DatabaseAccess = DatabaseAccess.getInstance()
    
    // Buttons on Page
    @IBOutlet weak var addGoalButton: UIButton!
    
    // Text Input Fields
    @IBOutlet weak var goalNameField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Pad and round the 'Add Goal' Button
        addGoalButton.layer.cornerRadius = 5
        addGoalButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Add Date Picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(AddGoalViewController.datePickerValueChanged(picker:)), for: UIControl.Event.valueChanged)
        
        // Tap to dismiss Date Picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddGoalViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dateField.inputView = datePicker
    }
    
    
    @IBAction func addGoalButtonPressed(_ sender: Any) {
        print("add goal pressed")
        // Get field values
        let goalName = goalNameField.text ?? ""
        let amount = amountField.text ?? ""
        let date = dateField.text ?? ""
        // Check field values
        if goalName == "" {
            createErrorAlert(title: "Goal name required")
        } else if amount == "" {
            createErrorAlert(title: "Target amount required")
        } else {
            // Convert amount field string to a double
            if Double(amountField.text!) != nil {
                print("Valid goal amount of \(amountField.text!)")
            } else {
                createErrorAlert(title: "Not a valid number: \(amountField.text!)")
                return
            }
            
            // Create goal
            let numAmount = Double(amountField.text!)
            let newGoal = Goal(userId: (Auth.auth().currentUser?.uid)!, title: goalName, target: numAmount ?? 100.0)
            // Set deadline
            let today = Date.init()
            if date != ""  {
                // TODO: error that deadline must be in future
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy" //Your date format
                //according to date format your date string
                guard let dateForm = dateFormatter.date(from: date) else {
                    fatalError()
                }
                print(dateForm)
                if (today < dateForm) {
                    newGoal.setDeadline(date: date)
                } else {
                    createErrorAlert(title: "That deadline has already passed.")
                    return
                }

            } else {
                createErrorAlert(title: "Please select a deadline.")
                return
            }
            // Add Goal and update user's current goal
            // Add Goal and update user's current goal
            let defaultGoal = Goal(userId: (Auth.auth().currentUser?.uid)!, title: "First Time Saver", target: 10000.00)
            let goalId1 = database.addGoal(goal: defaultGoal)
            database.addGoalToUser(goalId: goalId1, userId: (Auth.auth().currentUser?.uid)!)
            let goalId = database.addGoal(goal: newGoal)
            database.addGoalToUser(goalId: goalId, userId: (Auth.auth().currentUser?.uid)!)
            database.editGoalInUser(userId: (Auth.auth().currentUser?.uid)!, goalId: goalId)
            createSuccessAlert(title: "Goal Added!")
        }
    }
    
    
    @objc func datePickerValueChanged(picker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        dateField.text = formatter.string(from: picker.date)
    }
    
    // If view tapped, dismiss keyboard
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func createErrorAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createSuccessAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in self.performSegue(withIdentifier: "loginNewUser", sender: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }

}
