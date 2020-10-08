//
//  ChatMessageCell.swift
//  FirebaseApp
//
//  Created by Jack Colley on 08/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChatMessageCell: UITableViewCell {
    
    @IBOutlet weak var textViewMessageText: UILabel!
    
    @IBOutlet weak var imageViewChatUser: UIImageView!
    
    @IBOutlet weak var imageViewChatImage: UIImageView!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTimestampConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTimestamp: UILabel!
        
    @IBOutlet weak var latestMessageSeenIndicator: UIImageView!
    
    var chatMessage: ChatMessage?
    
    func configureCell(_ chatMessage: ChatMessage, _ sequential: Bool) {
        self.chatMessage = chatMessage
        
        if (chatMessage.fromId == Auth.auth().currentUser?.uid) {
            if chatMessage.id == FirebaseManager.manager.latestMessageSeen {
                self.latestMessageSeenIndicator.isHidden = false
            } else {
                self.latestMessageSeenIndicator.isHidden = true
            }
        }
        
        // Check who message is from and download correct profile picture
        if chatMessage.fromId == Auth.auth().currentUser?.uid {
            let ref = Storage.storage().reference(forURL: FirebaseManager.manager.currentUser.profileImageUrl)
            self.imageViewChatUser.sd_setImage(with: ref)
        } else {
            let ref = Storage.storage().reference(forURL: FirebaseManager.manager.otherUser.profileImageUrl)
            self.imageViewChatUser.sd_setImage(with: ref)
        }
        
        // Fix for image not filling ImageView
        self.imageViewChatUser.contentMode = .scaleAspectFill
        
//        if sequential {
//            self.imageViewChatUser.isHidden = true
//        } else {
//            self.imageViewChatUser.isHidden = false
//        }
        
        if chatMessage.imageUrl != nil {
            self.imageViewChatImage.image = UIImage()
            let ref = Storage.storage().reference(forURL: chatMessage.imageUrl!)
            self.imageViewChatImage.sd_setImage(with: ref)
            self.imageViewChatImage.layer.borderWidth = 1
            self.imageViewChatImage.layer.borderColor = UIColor.white.cgColor
            
            self.imageViewChatImage.contentMode = .scaleAspectFill
            
            if chatMessage.text.isEmpty {
                // Remove constraint
                self.imageViewTimestampConstraint.priority = UILayoutPriority(rawValue: 1000)
            } else {
                // Re-add constraint
                self.imageViewTimestampConstraint.priority = UILayoutPriority(rawValue: 700)
            }
        }
        
        if chatMessage.text.isEmpty {
            self.textViewMessageText.isHidden = true
        } else {
            self.textViewMessageText.text = chatMessage.text
            self.textViewMessageText.isHidden = false
        }
        
        self.textViewTimestamp.text = chatMessage.timestamp
    }
}
