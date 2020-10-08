//
//  LatestMessagesViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 02/09/2020.


import Foundation
import UIKit
import Firebase

//  Copyright © 2020 Jack. All rights reserved.
//

class LatestMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var latestMessageArray = [String : ChatMessage]()
    var sortedList = [Dictionary<String, ChatMessage>.Element]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        listenForLatestMessages()
        listenForOnlineUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        listenForLatestMessages()
        tableView.reloadData()
    }
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return latestMessageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = sortedList.index(sortedList.startIndex, offsetBy: indexPath.row)
        let message = sortedList[index].value
                    
        let cell = (tableView.dequeueReusableCell(withIdentifier: "LatestMessageCell") as! LatestMessageCell)

        cell.configureCell(message)
        
        cell.separatorInset = UIEdgeInsets.zero
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = sortedList.index(sortedList.startIndex, offsetBy: indexPath.row)
        let message = sortedList[index].value
        
        let otherUserId: String
        
        if message.fromId == FirebaseManager.manager.currentUser.uid {
            otherUserId = message.toId
        } else {
            otherUserId = message.fromId
        }
        
        let userRef = Database.database().reference().child("users/\(otherUserId)")
        userRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
            FirebaseManager.manager.otherUser = try! JSONDecoder().decode(ChatUser?.self, from: data)!
        })
        
        let ref = Database.database().reference().child("user-messages/\(FirebaseManager.manager.currentUser.uid)/\(otherUserId)/cid")
        ref.observe(.value, with: { snapshot in
//            FirebaseManager.manager.cid = snapshot.value! as! String
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
            vc.cid = snapshot.value! as? String
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: -
    
    func listenForOnlineUsers() {
        let ref = Database.database().reference()
        ref.child("online-users").observe(.childAdded, with: { snapshot in
            if snapshot.value as! Bool == true {
                FirebaseManager.manager.onlineUsers.append(snapshot.key)
                self.tableView.reloadData()
            }
        })
        ref.child("online-users").observe(.childChanged, with: { snapshot in
            if FirebaseManager.manager.onlineUsers.contains(snapshot.key) && snapshot.value as! Bool == false {
                FirebaseManager.manager.onlineUsers.removeAll(where: { $0 == snapshot.key })
                self.tableView.reloadData()
            } else {
                FirebaseManager.manager.onlineUsers.append(snapshot.key)
                self.tableView.reloadData()
            }
        })
    }
    
    func refreshLatestMessages(_ snapshot: DataSnapshot) {
        guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
        let a = try? JSONDecoder().decode(ChatMessage?.self, from: data)
        
        if FirebaseManager.manager.currentUser.blocklist != nil {
            if FirebaseManager.manager.currentUser.blocklist!.contains(a!.fromId) || FirebaseManager.manager.currentUser.blocklist!.contains(a!.toId) {
                return
            }
        }
        self.latestMessageArray[snapshot.key] = a
        
        self.sortedList = self.latestMessageArray.sorted(by: { $0.value.time > $1.value.time })
        
        self.tableView.reloadData()
    }
    
    func listenForLatestMessages() {
        self.latestMessageArray = [String : ChatMessage]()
        let ref = Database.database().reference().child("latest-messages")
        ref.child(FirebaseManager.manager.currentUser.uid).observe(.childAdded, with: { snapshot in
            self.refreshLatestMessages(snapshot)
            })
        
        ref.child(FirebaseManager.manager.currentUser.uid).observe(.childChanged, with: { snapshot in
            self.refreshLatestMessages(snapshot)
        })
    }
}
