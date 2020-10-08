//
//  NewConversationCell.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewConversationCell: UITableViewCell {
    
    
    @IBOutlet weak var imageViewNewConversation: UIImageView!
    
    @IBOutlet weak var textViewNewConversation: UILabel!
    
    func configureCell(_ user: ChatUser) {
        self.textViewNewConversation.text = user.username
        self.imageViewNewConversation.sd_setImage(with: Storage.storage().reference(forURL: user.profileImageUrl))
        self.imageViewNewConversation.contentMode = .scaleAspectFill
    }
}
