//
//  NewConversationViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchContacts()
    }
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = contacts[indexPath.row]
                    
        let cell = (tableView.dequeueReusableCell(withIdentifier: "NewConversationCell") as! NewConversationCell)

        cell.configureCell(user)
        
        cell.separatorInset = UIEdgeInsets.zero
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ref = Database.database().reference()
        let otherUser = contacts[indexPath.row]
        ref.child("user-messages/\(Auth.auth().currentUser!.uid)").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(otherUser.uid) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
                vc.cid = snapshot.childSnapshot(forPath: otherUser.uid).childSnapshot(forPath: "cid").value as? String
                self.navigationController?.pushViewController(vc, animated: true)
                FirebaseManager.manager.cid = snapshot.childSnapshot(forPath: otherUser.uid).childSnapshot(forPath: "cid").value as! String
                FirebaseManager.manager.otherUser = otherUser
                
//                self.performSegue(withIdentifier: "showChatNew", sender: self)
            } else {
                let cid = UUID.init().uuidString
                ref.child("user-messages/\(Auth.auth().currentUser!.uid)/\(otherUser.uid)/cid").setValue(cid, withCompletionBlock: { error, snapshot in
                    let otherRef = Database.database().reference()
                    otherRef.child("user-messages/\(otherUser.uid)/\(Auth.auth().currentUser!.uid)/cid").setValue(cid, withCompletionBlock: { error, snapshot in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
                        vc.cid = cid
                        self.navigationController?.pushViewController(vc, animated: true)
                        FirebaseManager.manager.cid = cid
                        FirebaseManager.manager.otherUser = otherUser
                        
//                        self.performSegue(withIdentifier: "showChatNew", sender: self)
                    })
                })
            }
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: -
    
    var contacts: [ChatUser] = []
    
    func fetchContacts() {
        if FirebaseManager.manager.currentUser.contacts != nil {
            for i in FirebaseManager.manager.currentUser.contacts! {
                let ref = Database.database().reference()
                ref.child("users/\(i)").observe(.value, with: { snapshot in
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                    let a = try? JSONDecoder().decode(ChatUser?.self, from: data)
                    self.contacts.append(a!)
                    self.contacts = self.contacts.sorted(by: { $1.username > $0.username })
                    
                    self.tableView.reloadData()
                })
            }
        }
    }
}
