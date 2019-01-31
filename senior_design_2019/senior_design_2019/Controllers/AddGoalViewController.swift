//
//  AddGoalViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 1/25/19.
//  Copyright © 2019 OIDUser. All rights reserved.
//

import UIKit

class AddGoalViewController: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var addGoalButton: UIButton!
    @IBOutlet weak var dateField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Pad and round the 'Skip' Button
        skipButton.layer.cornerRadius = 5
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
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
    

    @IBAction func skipButtonPressed(_ sender: Any) {
        print("skip button pressed")
    }
    
    @IBAction func addGoalButtonPressed(_ sender: Any) {
        print("add goal pressed")
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

}
