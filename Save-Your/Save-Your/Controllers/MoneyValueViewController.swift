//
//  MoneyValueViewController.swift
//  spend_to_save
//
//  Created by OIDUser on 1/25/19.
//  Copyright © 2019 OIDUser. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class MoneyValueViewController: UIViewController, CLLocationManagerDelegate{

    // Variables
    var database : DatabaseAccess = DatabaseAccess.getInstance()
    let locManager = CLLocationManager()
    var totalSavings : Double = 0.0
    
    // Buttons
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    // Labels
    @IBOutlet weak var totalSavingLabel: UILabel!
    @IBOutlet weak var saverLevelLabel: UILabel!
    @IBOutlet weak var nextLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            // creates an instance of a location manager and
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.startUpdatingLocation()
            self.locManager.requestAlwaysAuthorization()
        }
        
        // Add logo to navigation bar
        let logo = UIImage(named: "saveyour logo-40.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        // Pad and round the 'Logout' Button
        logoutButton.layer.cornerRadius = 5
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the '+' Button
        plusButton.layer.cornerRadius = 5
        plusButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the 'Logout' Button
        logoutButton.layer.cornerRadius = 5
        logoutButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Pad and round the '+' Button
        plusButton.layer.cornerRadius = 5
        plusButton.contentEdgeInsets = UIEdgeInsets(top: 10,left: 10,bottom: 7,right: 10)
        
        // Populate homescreen graphics
        self.database.getUserTotalSavings(uid: Auth.auth().currentUser!.uid, callback: {(totalSav) -> Void in
            print("got total sav/\(totalSav)")
            self.totalSavings = totalSav ?? 0.0
            let formattedTotalSavings = self.formatDollarAmount(amount: totalSav ?? 0.0)
            self.totalSavingLabel.text = "Lifetime savings of $\(formattedTotalSavings)"
            // Display saver level
            let saverLevel = self.getSaverLevel(totalSav: self.totalSavings)
            self.saverLevelLabel.text = "\(saverLevel) level"
            let amountLeft = self.getNextLevel(totalSav: self.totalSavings)
            let formattedAmountLeft = self.formatDollarAmount(amount: amountLeft)
            if amountLeft == -1 {
                self.nextLevelLabel.text = ""
            } else {
                self.nextLevelLabel.text = "Save $\(formattedAmountLeft) more to reach next level"
            }
        })
        
//        print("curr location\(locManager.location)")
//        if (CLLocationManager.locationServicesEnabled()) {
//            let geocoder = CLGeocoder()
//            // Get location of device
//            let deviceLatitude = locManager.location?.coordinate.latitude
//            let deviceLongitude = locManager.location?.coordinate.longitude
//            print("Devices lat = \(deviceLatitude!) and lon = \(deviceLongitude!)")
//
//            let address = "3401 Walnut St, Philadelphia, PA 19104"
//            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
//                if ((error) != nil){
//                    print("Error", error ?? "")
//                }
//                if let placemark = placemarks?.first {
//                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//                    // Get latitude and longitude of house
//                    let lat = coordinates.latitude
//                    let lon = coordinates.longitude
//                    // Calculate distance between house and device
//                                        let latDif = abs(lat - deviceLatitude!)
//                                        let lonDif = abs(lon - deviceLongitude!)
//                                        print("latitude difference = \(latDif)")
//                                        print("longitude difference = \(lonDif)")
//                                        // Notify user if device is within 0.0001 km (about 36 feet)
//                                        if latDif < 0.0001 && lonDif < 0.0001 {
//                                            self.createAlert(title: "Looks like you are in Starbucks. Want to log a saving transaction?")
//                                        }
//
//                }
//            })
//        }
    
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.database.logout(view: self)
        performSegue(withIdentifier: "unwindSegueToLogout", sender: self)
    }
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SaveMoney", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SaveMoneyController") as UIViewController
        self.navigationController?.pushViewController(vc, animated: true)
//        self.performSegue(withIdentifier: "logSavingSegue", sender: self)
    }
    
    
    func createAlert(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Denote anchor for unwinding to home
    @IBAction func unwindToHome(segue:UIStoryboardSegue) { }
    
    // Retrieves user's saving level based on total savings
    func getSaverLevel(totalSav: Double) -> String {
        if totalSav < 10 {
            return "Green"
        } else if totalSav < 50 {
            return "Black"
        } else if totalSav < 100 {
            return "Bronze"
        } else if totalSav < 250 {
            return "Silver"
        } else if totalSav < 500 {
            return "Gold"
        } else if totalSav < 1000 {
            return "Platinum"
        } else if totalSav < 2500 {
            return "Emerald"
        } else if totalSav < 5000 {
            return "Ruby"
        } else if totalSav < 10000 {
            return "Sapphire"
        } else {
            return "Diamond"
        }
    }
    
    // Calculates amount to next saving level
    func getNextLevel(totalSav: Double) -> Double {
        if totalSav < 10 {
            return 10 - totalSav
        } else if totalSav < 50 {
            return 50 - totalSav
        } else if totalSav < 100 {
            return 100 - totalSav
        } else if totalSav < 250 {
            return 250 - totalSav
        } else if totalSav < 500 {
            return 500 - totalSav
        } else if totalSav < 1000 {
            return 1000 - totalSav
        } else if totalSav < 2500 {
            return 2500 - totalSav
        } else if totalSav < 5000 {
            return 5000 - totalSav
        } else if totalSav < 10000 {
            return 10000 - totalSav
        } else {
            return -1
        }
    }
    
    // Format double from DB to proper dollar amount
    func formatDollarAmount(amount: Double) -> String {
        let timesHundred = 100 * amount
        let rounded = round(timesHundred) / 100
        let returnVal : String = String(format: "%.2f", rounded)
        return returnVal
    }
    
}
