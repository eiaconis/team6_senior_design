//
//  GoalDetailsViewController.swift
//  Save-Your
//
//  Created by OIDUser on 4/14/19.
//

import UIKit

class GoalDetailsViewController: UIViewController {

    // Variables
    var database : DatabaseAccess = DatabaseAccess.getInstance()
    var goalID : String = ""
    var goalName : String = ""
    var targetAmount : Double = 0.0
    var amountSaved : Double = 0.0
    
    // Labels
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var currentAmountLabel: UILabel!
    @IBOutlet weak var percentSavedLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    
    
    // Bar
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goalNameLabel.text = goalName
        
        // Format progress bar
        progressBar.transform = progressBar.transform.scaledBy(x: 1, y: 20)
        
        self.database.getTargetOfGoal(goalId: self.goalID, callback: {(target) -> Void in
            self.targetAmount = target ?? 0.0
            self.targetLabel.text = "$\(self.formatDouble(amount: self.targetAmount))"
            if self.targetAmount > 0 {
                self.database.getStateOfGoal(goalId: self.goalID, callback: {(amountSaved) -> Void in
                    self.amountSaved = amountSaved ?? 0.0
                    let progress = self.amountSaved / self.targetAmount
                    self.progressBar.setProgress(Float(progress), animated: true)
                    self.percentSavedLabel.text = "\(self.formatDouble(amount: progress * 100))%"
                    self.currentAmountLabel.text = "$\(self.formatDouble(amount: self.amountSaved))"
                })
            }
        })
    }
    
    // Format double from DB to two decimals
    func formatDouble(amount: Double) -> String {
        return String(format: "%.2f", round(100 * amount) / 100)
    }

}
