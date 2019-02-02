//
//  Transaction.swift
//  senior_design_2019
//
//  Created by Elena Iaconis on 1/30/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import Foundation

class Transaction {
    
    var transactionId: String?
    var userId: String?
    var amount: NSNumber?
    var category: String?
    var goalId: String?
    var info: String?
    var timestamp: String?
    
    // Sets user id to unique identifier created when it is added to database
    func setTransactionId(id: String) {
        if transactionId == nil {
            self.transactionId = id
        }
    }
    
}
