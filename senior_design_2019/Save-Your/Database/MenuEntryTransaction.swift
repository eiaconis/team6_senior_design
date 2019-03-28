//
//  MenuEntryTransaction.swift - Subclass of Transaction
//  senior_design_2019
//
//  Created by Elena Iaconis on 1/30/19.
//  Copyright © 2019 Team 6. All rights reserved.
//

import Foundation

class MenuEntryTransaction: Transaction {
    
    var itemPurchased : String?
    var priceItemPurchased : Double?
    var itemDesired : String?
    var priceItemDesired : Double?
    var perceivedAmount : Double?
    
    
    override func isManualEntryTransaction() -> Bool {
        return false
    }
    
    override func getItemPurchased() -> String? {
        return self.itemPurchased
    }
    
    override func getPriceItemPurchased() -> Double? {
        return self.priceItemPurchased
    }
    
    override func getItemDesired() -> String? {
        return self.itemDesired
    }
    
    override func getPriceItemDesired() -> Double? {
        return self.priceItemDesired
    }
    
    override func getPricePerceived() -> Double? {
        return self.perceivedAmount
    }
    
}
