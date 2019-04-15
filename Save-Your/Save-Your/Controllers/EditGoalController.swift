//
//  EditGoalController.swift
//  Save-Your
//
//  Created by OIDUser on 4/14/19.
//

import UIKit

class EditGoalController: UIViewController {
    
    // Variables
    var database : DatabaseAccess = DatabaseAccess.getInstance()
    var goalName : String = ""
    var goalID : String = ""
    var goalTarget : Double = 0.0
    var deadline : String = ""
    var amountSaved : Double = 0.0
    
    // Buttons
    @IBOutlet weak var saveButton: UIButton!
    
    // Labels
    @IBOutlet weak var goalNameLabel: UILabel!
    
    // Fields
    @IBOutlet weak var targetAmountField: UITextField!
    @IBOutlet weak var deadlineField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If screen tapped, dismiss keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Add delete button to navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteConfirmAlert))
        
        // Pad and round the 'Save' Button
        saveButton.layer.cornerRadius = 5
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Update page title
        goalNameLabel.text = "Edit Goal:\n\(goalName)"
        
        // Populate placeholder text
        targetAmountField.placeholder = "$\(self.formatDouble(amount: self.goalTarget))"
        deadlineField.placeholder = self.deadline
        
        // Add Date Picker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(AddGoalViewController.datePickerValueChanged(picker:)), for: UIControl.Event.valueChanged)
        
        // Tap to dismiss Date Picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddGoalViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
        
        deadlineField.inputView = datePicker
    }
    
    @objc func datePickerValueChanged(picker: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        let newDate = formatter.string(from: picker.date)
        self.deadline = newDate
        deadlineField.text = newDate
    }
    
    // If view tapped, dismiss picker
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if targetAmountField.text != targetAmountField.placeholder && targetAmountField.text != "" {
            // Check that target amount is more than what is already saved
            let newTarget = Double(targetAmountField.text!) ?? 0.0
            if newTarget < self.amountSaved {
                createAlert(title: "New target amount must be greater than amount currently saved towards goal ($\(self.formatDouble(amount: self.amountSaved))).  Please try again")
            } else {
                self.goalTarget = newTarget
                self.targetAmountField.placeholder = "$\(self.formatDouble(amount: Double(targetAmountField.text!) ?? 0.0))"
                self.database.setGoalTarget(goalID: self.goalID, newAmount: newTarget)
            }
        }
        if deadlineField.text != deadlineField.placeholder && deadlineField.text != "" {
            // Check that target amount is more than what is already saved
            let df = DateFormatter()
            let calendar = Calendar.current
            df.calendar = calendar
            df.dateFormat = "MMM d, yyyy"
            let newDeadline = deadlineField.text!
            let newDeadlineDate = df.date(from: newDeadline)!
            let currentDate = Date()
            if newDeadlineDate <= currentDate {
                createAlert(title: "New deadline must be some day in the future.  Please try again.")
            } else {
                self.deadline = newDeadline
                self.deadlineField.placeholder = newDeadline
                self.database.setGoalDeadline(goalID: self.goalID, newDeadline: newDeadline)
            }
        }
        createSuccessfulEditAlert(title: "Goal details saved!")
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createSuccessfulEditAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in self.performSegue(withIdentifier: "unwindSegueToGoalDetails", sender: self)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Format double from DB to two decimals
    func formatDouble(amount: Double) -> String {
        return String(format: "%.2f", round(100 * amount) / 100)
    }

    
    // Denotes action for delete button in navigation bar
    @objc public func deleteConfirmAlert() {
        let alert = UIAlertController(title: "Are you sure you wish to delete \(self.goalName)?  This action cannot be undone", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { (action) in self.deleteGoalAndUnwind()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Handles deletion of goal and unwinding to home
    func deleteGoalAndUnwind() {
        self.database.deleteGoal(goalID: self.goalID)
        self.performSegue(withIdentifier: "unwindSegueToGoalFeed", sender: self)
    }

}
