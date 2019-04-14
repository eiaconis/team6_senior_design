//
//  MenuItemViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class MenuItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var menu : [Any] = []
    var totalMenu : NSDictionary = [:]
    var sizeVal = "tall_price"
    var itemPurchasedPrice : Double = 0.0
    var database : DatabaseAccess = DatabaseAccess.getInstance()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var size: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        self.database.getMenu(callback: {(men) -> Void in
            self.totalMenu = men
            self.menu = men.allKeys
            self.tableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = (menu[indexPath.row]) as! String
        cell.textLabel?.font = UIFont(name:"DIN Condensed", size:20)
       // print(menu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var prices : NSDictionary = totalMenu[menu[indexPath.row]]! as! NSDictionary
        self.itemPurchasedPrice = (prices[sizeVal]! as! NSString).doubleValue
        print("item got price \(self.itemPurchasedPrice)")
        self.performSegue(withIdentifier: "menuItemSegue", sender: self)
    }
    
    @IBAction func sizeChange(_ sender: UISegmentedControl) {
        print("# of Segments = \(sender.numberOfSegments)")
        
        switch sender.selectedSegmentIndex {
        case 0:
            print("first segement clicked")
            sizeVal = "tall_price"
        case 1:
            print("second segment clicked")
            sizeVal = "grande_price"
        case 2:
            print("third segemnet clicked")
            sizeVal = "venti_price"
        default:
            break;
        }  //Switch
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is IdealMenuItemViewController {
            // Pass purchased item price to next page
            let vc = segue.destination as? IdealMenuItemViewController
            vc?.itemPurchasedPrice = self.itemPurchasedPrice
        }
    }
}
