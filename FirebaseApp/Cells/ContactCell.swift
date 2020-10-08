//
//  ContactCell.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseUI

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var imageViewContact: UIImageView!
    
    @IBOutlet weak var textViewContact: UILabel!
    
    func configureCell(_ user: ChatUser) {
        self.textViewContact.text = user.username
        self.imageViewContact.sd_setImage(with: Storage.storage().reference(forURL: user.profileImageUrl))
        self.imageViewContact.contentMode = .scaleAspectFill
    }
}
