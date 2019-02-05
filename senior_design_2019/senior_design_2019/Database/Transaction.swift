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
    var amount: Double?
    var goalId: String?
    var info: String?
    var timestamp: String?
    
    init(userId: String, amount: Double, goalId: String) {
        self.userId = userId
        self.amount = amount
        self.goalId = goalId
    }
    
    // Sets user id to unique identifier created when it is added to database
    func setTransactionId(id: String) {
        if transactionId == nil {
            self.transactionId = id
        }
    }
    
    func isManualEntryTransaction() -> Bool {
        return true
    }
    
    func getCategory() -> String? {
        return nil
    }
    
    func getItemPurchased() -> String? {
        return nil
    }
    
    func getPriceItemPurchased() -> Double? {
        return nil
    }
    
    func getItemDesired() -> String? {
        return nil
    }
    
    func getPriceItemDesired() -> Double? {
        return nil
    }
    
    func getPricePerceived() -> Double? {
        return nil
    }
    
    
}
