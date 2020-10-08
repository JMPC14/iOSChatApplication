//
//  SettingsViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class SettingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                // Blocked users
                print("blocked")
            case 1:
                print("test")
            case 2:
                print("test")
            default:
                print("test 2")
            }
        case 1:
            switch indexPath.row {
            case 0:
                print("test 4")
            case 1:
                print("test")
            case 2:
                print("test")
            default:
                print("test 5")
            }
        case 2:
            switch indexPath.row {
            case 0:
                print("test")
            case 1:
                print("test")
            case 2:
                // Sign Out
                let alert = UIAlertController(title: "Sign out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
                    print("Confirmed sign out")
                    do { try Auth.auth().signOut() }
                    catch { print("sign out failed") }
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInNavController")
                    
                    UIApplication.shared.windows.first?.rootViewController = vc
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                    
                    Database.database().reference(withPath: "online-users/\(FirebaseManager.manager.currentUser.uid)").setValue(false)
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            default:
                print("end test")
            }
        default:
            print("test 3")
        }
    }
}
