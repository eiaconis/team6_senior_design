//
//  AddGoalFromPageController.swift
//  senior_design_2019
//
//  Created by OIDUser on 1/31/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import UIKit

class AddGoalFromPageController: UIViewController {
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pad and round the 'Cancel' Button
        cancelButton.layer.cornerRadius = 5
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the 'Add' Button
        addButton.layer.cornerRadius = 5
        addButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
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
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        createAlert(title: "Goal Added!")
    }
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in self.performSegue(withIdentifier: "addGoalSegue", sender: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
