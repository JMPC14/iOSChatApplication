//
//  ContactsViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchContacts()
    }
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = contacts[indexPath.row]
                    
        let cell = (tableView.dequeueReusableCell(withIdentifier: "ContactCell") as! ContactCell)

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
            FirebaseManager.manager.currentUser.contacts!.removeAll(where: { $0 == contacts[indexPath.row].uid })
            contacts.remove(at: indexPath.row)
            
            let ref = Database.database().reference()
            ref.child("users/\(Auth.auth().currentUser!.uid)/contacts").setValue(FirebaseManager.manager.currentUser.contacts)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    //MARK: -
    
    var contacts: [ChatUser] = []
    
    func fetchContacts() {
        self.contacts = []
        if FirebaseManager.manager.currentUser.contacts != nil {
            for i in FirebaseManager.manager.currentUser.contacts! {
                let ref = Database.database().reference()
                ref.child("users/\(i)").observe(.value, with: { snapshot in
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                    let a = try? JSONDecoder().decode(ChatUser?.self, from: data)
                    let contain: Bool =  self.contacts.contains { $0.username == a!.username }
                    self.contacts.append(a!)
                    if !contain {
                        self.contacts = self.contacts.sorted(by: { $1.username > $0.username })
                        
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
}
