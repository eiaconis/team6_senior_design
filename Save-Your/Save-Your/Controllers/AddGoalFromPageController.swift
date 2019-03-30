//
//  AddGoalFromPageController.swift
//  senior_design_2019
//
//  Created by OIDUser on 1/31/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AddGoalFromPageController: UIViewController {
    
    let database : DatabaseAccess = DatabaseAccess.getInstance()
    
    // Buttons
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // Text Fields
    @IBOutlet weak var goalNameField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pad and round the 'Cancel' Button
        cancelButton.layer.cornerRadius = 5
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the 'Add' Button
        addButton.layer.cornerRadius = 5
        addButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Add Date Picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(AddGoalViewController.datePickerValueChanged(picker:)), for: UIControl.Event.valueChanged)
        
        // Tap to dismiss Date Picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddGoalViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        dateField.inputView = datePicker
    }
    
    @objc func datePickerValueChanged(picker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        dateField.text = formatter.string(from: picker.date)
        print(dateField.text)
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        // Get field values
        let goalName = goalNameField.text ?? ""
        let amount = amountField.text ?? ""
        let date = dateField.text ?? ""
        print("goalName = \(goalName)")
        print("amount = \(amount)")
        print("date = \(date)")
        
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
                // error that deadline must be in future
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy" //Your date format
                //according to date format your date string
                guard let dateForm = dateFormatter.date(from: date) else {
                    fatalError()
                }
                print(dateForm)
                if (today < dateForm) {
                    print("HERE")
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
            let goalId = database.addGoal(goal: newGoal)
            database.addGoalToUser(goalId: goalId, userId: (Auth.auth().currentUser?.uid)!)
            createSuccessAlert(title: "Goal Added!")
        }
    }
    
    func createErrorAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createSuccessAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in self.performSegue(withIdentifier: "addGoalSegue", sender: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
