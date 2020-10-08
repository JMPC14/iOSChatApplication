//
//  NewContactViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchUsers()
    }
    
    //MARK: - Table View Methods
    
    var users: [ChatUser] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
                    
        let cell = (tableView.dequeueReusableCell(withIdentifier: "NewContactCell") as! NewContactCell)

        cell.configureCell(user)
        
        cell.separatorInset = UIEdgeInsets.zero
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        if FirebaseManager.manager.currentUser.contacts == nil {
            FirebaseManager.manager.currentUser.contacts = [String]()
        }
        
        FirebaseManager.manager.currentUser.contacts!.append(user.uid)
        
        let ref = Database.database().reference()
        ref.child("users/\(Auth.auth().currentUser!.uid)/contacts").setValue(FirebaseManager.manager.currentUser.contacts) { error, reference in
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: -
    
    func fetchUsers() {
        let ref = Database.database().reference()
        ref.child("users").observe(.childAdded, with: { snapshot in
            guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
            let a = try? JSONDecoder().decode(ChatUser?.self, from: data)
            if (FirebaseManager.manager.currentUser.contacts != nil) {
                if a?.uid != Auth.auth().currentUser?.uid && !FirebaseManager.manager.currentUser.contacts!.contains(a!.uid) {
                    self.users.append(a!)
                }
            } else if a?.uid != Auth.auth().currentUser?.uid {
                self.users.append(a!)
            }
            
            self.tableView.reloadData()
        })
    }
}
