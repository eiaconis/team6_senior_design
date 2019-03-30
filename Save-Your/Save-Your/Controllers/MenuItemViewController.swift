//
//  MenuItemViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 12/6/18.
//  Copyright © 2018 OIDUser. All rights reserved.
//

import UIKit

class MenuItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let menu = ["Small Coffee", "Medium Coffee", "Large Coffee"]
    let menuPrice = [1.00, 2.00, 3.00]
    var itemPurchasedPrice : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = menu[indexPath.row]
        cell.textLabel?.font = UIFont(name:"DIN Condensed", size:20)
        print(menu[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.itemPurchasedPrice = menuPrice[indexPath.row]
        self.performSegue(withIdentifier: "menuItemSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is IdealMenuItemViewController {
            // Pass purchased item price to next page
            let vc = segue.destination as? IdealMenuItemViewController
            vc?.itemPurchasedPrice = self.itemPurchasedPrice
        }
    }
}
