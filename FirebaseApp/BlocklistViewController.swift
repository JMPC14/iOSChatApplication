//
//  BlocklistViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class BlocklistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var blocklist: [ChatUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchBlocklist()
    }
    
    //MARK: - Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blocklist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = blocklist[indexPath.row]
                    
        let cell = (tableView.dequeueReusableCell(withIdentifier: "BlocklistCell") as! BlocklistCell)

        cell.configureCell(user)
        
        cell.separatorInset = UIEdgeInsets.zero
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FirebaseManager.manager.currentUser.blocklist!.removeAll(where: { $0 == blocklist[indexPath.row].uid })
            blocklist.remove(at: indexPath.row)
            
            let ref = Database.database().reference()
            ref.child("users/\(Auth.auth().currentUser!.uid)/blocklist").setValue(FirebaseManager.manager.currentUser.blocklist)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

    //MARK: -
    
    func fetchBlocklist() {
        self.blocklist = []
        if FirebaseManager.manager.currentUser.blocklist != nil {
            for i in FirebaseManager.manager.currentUser.blocklist! {
                let ref = Database.database().reference()
                ref.child("users/\(i)").observe(.value, with: { snapshot in
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                    let a = try? JSONDecoder().decode(ChatUser?.self, from: data)
                    self.blocklist.append(a!)
                    self.blocklist = self.blocklist.sorted(by: { $1.username > $0.username })
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
}
