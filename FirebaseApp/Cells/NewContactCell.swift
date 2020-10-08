//
//  NewContactCell.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NewContactCell: UITableViewCell {
    
    @IBOutlet weak var imageViewNewContact: UIImageView!
    
    @IBOutlet weak var textViewNewContact: UILabel!
    
    func configureCell(_ user: ChatUser) {
        self.textViewNewContact.text = user.username
        self.imageViewNewContact.sd_setImage(with: Storage.storage().reference(forURL: user.profileImageUrl))
        self.imageViewNewContact.contentMode = .scaleAspectFill
    }
}
