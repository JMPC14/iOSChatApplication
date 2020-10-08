//
//  LatestMessageCell.swift
//  FirebaseApp
//
//  Created by Jack Colley on 07/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import SwiftyAvatar

class LatestMessageCell: UITableViewCell {

    @IBOutlet weak var latestMessageImageView: UIImageView!
    
    @IBOutlet weak var latestMessageUsername: UILabel!
    
    @IBOutlet weak var latestMessageMessage: UILabel!
        
    @IBOutlet weak var imageViewOnlineIndicator: UIImageView!
        
    func configureCell(_ message: ChatMessage) {
        self.imageViewOnlineIndicator.isHidden = true
        
        let ref = Database.database().reference(withPath: "users")
        var observeId: String?
        if message.fromId != Auth.auth().currentUser!.uid {
            observeId = message.fromId
            ref.child(observeId!).observe(.value, with: { snapshot in
                guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                let user = try? JSONDecoder().decode(ChatUser?.self, from: data)
                self.latestMessageUsername.text = user?.username
                
                let ref = Storage.storage().reference(forURL: user!.profileImageUrl)
                
                self.latestMessageImageView.sd_setImage(with: ref)
                if FirebaseManager.manager.onlineUsers.contains(observeId!) {
                    self.imageViewOnlineIndicator.isHidden = false
                }
                self.latestMessageImageView.contentMode = .scaleAspectFill
            })
        } else {
            observeId = message.toId
            ref.child(observeId!).observe(.value, with: { snapshot in
                guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                let user = try? JSONDecoder().decode(ChatUser?.self, from: data)
                self.latestMessageUsername.text = user?.username
                
                let ref = Storage.storage().reference(forURL: user!.profileImageUrl)
                
                self.latestMessageImageView.sd_setImage(with: ref)
                if FirebaseManager.manager.onlineUsers.contains(observeId!) {
                    self.imageViewOnlineIndicator.isHidden = false
                }
                self.latestMessageImageView.contentMode = .scaleAspectFill
            })
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            latestMessageMessage.text = "You: \(message.text)"
            if message.imageUrl != nil {
                latestMessageMessage.text = "You sent a file."
                latestMessageMessage.font = UIFont.italicSystemFont(ofSize: 17)
            } else {
                latestMessageMessage.font = UIFont.systemFont(ofSize: 17)
            }
        } else {
            latestMessageMessage.text = "Them: \(message.text)"
            if message.imageUrl != nil {
                latestMessageMessage.text = "They sent a file."
                latestMessageMessage.font = UIFont.italicSystemFont(ofSize: 17)
            } else {
                latestMessageMessage.font = UIFont.systemFont(ofSize: 17)
            }
        }
    }
}
