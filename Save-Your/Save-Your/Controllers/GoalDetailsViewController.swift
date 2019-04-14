//
//  GoalDetailsViewController.swift
//  Save-Your
//
//  Created by OIDUser on 4/14/19.
//

import UIKit

class GoalDetailsViewController: UIViewController {

    // Variables
    var goalName : String = ""
    
    // Labels
    @IBOutlet weak var goalNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goalNameLabel.text = goalName
    }

}
