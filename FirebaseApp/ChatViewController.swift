//
//  ChatViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 07/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SafariServices

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imagePickerController = UIImagePickerController()
    var attachedImage: UIImage?
    var attachedImageUrl: String?
    var previousUser: String?
    
    var cid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = FirebaseManager.manager.otherUser.username
        
        tableView.delegate = self
        tableView.dataSource = self
        
        listenForMessages()
        listenForTypingIndicators()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textFieldMessage: UITextField!
    
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var textViewUserTyping: UILabel!
    
    // Update typing indicator
    @IBAction func textFieldChanged(_ sender: Any) {
        let ref = Database.database().reference(withPath: "user-messages/\(FirebaseManager.manager.otherUser.uid)/\(FirebaseManager.manager.currentUser.uid)")
        if !self.textFieldMessage.text!.isEmpty {
            ref.child("typing").setValue(true)
            self.sendMessageButton.isEnabled = true
        } else {
            ref.child("typing").setValue(false)
            self.sendMessageButton.isEnabled = false
        }
    }
    
    @IBAction func sendMessageButtonPressed(_ sender: Any) {
        let ref = Database.database().reference().child("conversations/\(self.cid!)").childByAutoId()
        let text = self.textFieldMessage.text
        
        let date = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.day], from: date)
        let dayOfMonth = components.day
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let nameOfMonth = dateFormatter.string(from: date)
        components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour!
        let minute = components.minute!
        var newHour = ""
        var newMinute = ""
        if hour < 10 {
            newHour = "0\(hour)"
        } else {
            newHour = String(hour)
        }
        if minute < 10 {
            newMinute = "0\(minute)"
        } else {
            newMinute = String(minute)
        }
        
        let chatMessage = ChatMessageNew(
            FirebaseManager.manager.currentUser.uid,
            ref.key!,
            text!,
            Int(NSDate().timeIntervalSince1970),
            "\(dayOfMonth!) \(nameOfMonth), \(newHour):\(newMinute)",
            FirebaseManager.manager.otherUser.uid
        )
        
        if self.attachedImage != nil {
            chatMessage.imageUrl = self.attachedImageUrl!
        }
                        
        ref.setValue(chatMessage.toAnyObject())
        
        let latestMessageRef = Database.database().reference()
        latestMessageRef.child("latest-messages/\(chatMessage.fromId)/\(chatMessage.toId)").setValue(chatMessage.toAnyObject())
        
        let latestMessageToRef = Database.database().reference()
        latestMessageToRef.child("latest-messages/\(chatMessage.toId)/\(chatMessage.fromId)").setValue(chatMessage.toAnyObject())
        
        scrollToBottom(true)
        let typingRef = Database.database().reference(withPath: "user-messages/\(FirebaseManager.manager.otherUser.uid)/\(FirebaseManager.manager.currentUser.uid)")
        typingRef.child("typing").setValue(false)
        self.attachedImage = nil
        self.attachedImageUrl = nil
        self.textFieldMessage.text = ""
    }
    
    //MARK: - Image Button Methods
    
    @IBAction func attachImageButtonPressed(_ sender: Any) {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
        sendMessageButton.isEnabled = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[.originalImage] as? UIImage {
            attachedImage = image
            let filename = UUID.init().uuidString
            let ref = Storage.storage().reference().child("images/\(filename)")
            let uploadData = self.attachedImage!.pngData()
            let metadata = StorageMetadata()
            metadata.contentType = "image/png"
            ref.putData(uploadData!, metadata: metadata, completion: { metadata, error in
                ref.downloadURL(completion: { url, error in
                    if (url != nil) {
                        self.attachedImageUrl = url!.absoluteString
                        self.sendMessageButton.isEnabled = true
                    } else {
                        print(error!)
                        self.sendMessageButton.isEnabled = true
                    }
                })
            })
        } else {
            print("Take another")
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Table View Methods
    
    var messages = [ChatMessage]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell: ChatMessageCell
        
        if (message.imageUrl != nil) {
            if message.fromId == Auth.auth().currentUser?.uid {
                cell = (tableView.dequeueReusableCell(withIdentifier: "ChatMessageFromImageCell") as! ChatMessageCell)
            } else {
                cell = (tableView.dequeueReusableCell(withIdentifier: "ChatMessageToImageCell") as! ChatMessageCell)
                let ref = Database.database().reference(withPath: "user-messages/\(FirebaseManager.manager.otherUser.uid)/\(FirebaseManager.manager.currentUser.uid)")
                ref.child("latestMessageSeen").setValue(message.id)
            }
        } else {
            if message.fromId == Auth.auth().currentUser?.uid {
                cell = (tableView.dequeueReusableCell(withIdentifier: "ChatMessageFromCell") as! ChatMessageCell)
            } else {
                cell = (tableView.dequeueReusableCell(withIdentifier: "ChatMessageToCell") as! ChatMessageCell)
                let ref = Database.database().reference(withPath: "user-messages/\(FirebaseManager.manager.otherUser.uid)/\(FirebaseManager.manager.currentUser.uid)")
                ref.child("latestMessageSeen").setValue(message.id)
            }
        }

        if message.fromId == self.previousUser {
            cell.configureCell(message, true)
        } else {
            cell.configureCell(message, false)
        }
        
        self.previousUser = message.fromId
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show action sheet for chat message
        let cell = tableView.cellForRow(at: indexPath) as! ChatMessageCell
        
        var a: ChatUser?
        
        if cell.chatMessage != nil {
            if cell.chatMessage?.fromId != Auth.auth().currentUser?.uid {
                let ref = Database.database().reference().child("users/\(cell.chatMessage!.fromId)")
                ref.observe(.value, with: { snapshot in
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                    a = try? JSONDecoder().decode(ChatUser?.self, from: data)
                    
                    let alert = UIAlertController(title: a!.username, message: "Select an action", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Block User", style: .destructive, handler: { _ in
                        if FirebaseManager.manager.currentUser.blocklist == nil {
                            FirebaseManager.manager.currentUser.blocklist = [String]()
                        }
                        FirebaseManager.manager.currentUser.blocklist?.append(a!.uid)
                        let blockRef = Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)")
                        blockRef.child("blocklist").setValue(FirebaseManager.manager.currentUser.blocklist, withCompletionBlock: { error, snapshot in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }))
                    alert.addAction(UIAlertAction(title: "View Profile", style: .default, handler: { _ in
                        
                    }))
                    if cell.chatMessage!.imageUrl != nil {
                        alert.addAction(UIAlertAction(title: "View Image", style: .default, handler: { _ in
                            let svc = SFSafariViewController(url: URL(string: cell.chatMessage!.imageUrl!)!)
                            self.present(svc, animated: true, completion: nil)
                        }))
                    }
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                })
            }
        }
    }
    
    //MARK: - Listening methods
    
    func listenForMessages() {
        let ref = Database.database().reference()
        ref.child("conversations/\(self.cid!)").observe(.childAdded, with: { snapshot in
            guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
            let a = try? JSONDecoder().decode(ChatMessage?.self, from: data)
            self.messages.append(a!)
            self.tableView.reloadData()
            self.scrollToBottom(false)
        })
    }
    
    @IBOutlet weak var userTypingTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userTypingBottomConstraint: NSLayoutConstraint!
        
    func listenForTypingIndicators() {
        
        func checkSnapshot(_ snapshot: DataSnapshot) {
            
            if snapshot.key == "typing" {
                if snapshot.value as! Bool == true {
                    self.textViewUserTyping.text = "\(FirebaseManager.manager.otherUser.username) is typing..."
                    self.textViewUserTyping.isHidden = false
                    self.userTypingTopConstraint.constant = 8
                } else if snapshot.value as! Bool == false {
                    self.textViewUserTyping.text = ""
                    self.textViewUserTyping.isHidden = true
                    self.userTypingTopConstraint.constant = 0
                }
            } else if snapshot.key == "latestMessageSeen" {
                FirebaseManager.manager.latestMessageSeen = snapshot.value as! String
                self.tableView.reloadData()
            }
        }
        
        let ref = Database.database().reference(withPath: "user-messages/\(FirebaseManager.manager.currentUser.uid)/\(FirebaseManager.manager.otherUser.uid)")
        ref.observe(.childAdded, with: { snapshot in
            checkSnapshot(snapshot)
        })
        ref.observe(.childChanged, with: { snapshot in
            checkSnapshot(snapshot)
        })
    }
    
    func scrollToBottom(_ animated: Bool) {
        DispatchQueue.main.async {
            if !self.messages.isEmpty {
                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
}
