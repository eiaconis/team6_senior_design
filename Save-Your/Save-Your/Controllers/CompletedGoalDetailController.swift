//
//  CompletedGoalDetailController.swift
//  Save-Your
//
//  Created by OIDUser on 4/16/19.
//

import UIKit

class CompletedGoalDetailController: UIViewController {
    
    // Variables
    let database : DatabaseAccess = DatabaseAccess.getInstance()
    var goalName : String = ""
    var goalID : String = ""
    
    // Labels
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var goalTargetLabel: UILabel!
    
    // Progress Bar
    @IBOutlet weak var progressBar: UIProgressView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        goalNameLabel.text = goalName
        
        // Format progress bar
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 20)
        progressBar.setProgress(Float(1), animated: true)
        
        self.database.getTargetOfGoal(goalId: self.goalID, callback: {(target) -> Void in
            let targetAmount = target ?? 0.0
            let properAmount = self.formatDouble(amount: targetAmount)
            self.goalTargetLabel.text = "$\(properAmount)"
            self.currentAmountLabel.text = "$\(properAmount)"
        })
    }
    
    // Format double from DB to two decimals
    func formatDouble(amount: Double) -> String {
        return String(format: "%.2f", round(100 * amount) / 100)
    }

}
