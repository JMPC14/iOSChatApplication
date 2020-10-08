//
//  BlocklistCell.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class BlocklistCell: UITableViewCell {
    
    @IBOutlet weak var imageViewBlocklist: UIImageView!
    
    @IBOutlet weak var textViewBlocklist: UILabel!
    
    var user: ChatUser?
    
    func configureCell(_ user: ChatUser) {
        self.user = user
        
        self.textViewBlocklist.text = user.username
        self.imageViewBlocklist.sd_setImage(with: Storage.storage().reference(forURL: user.profileImageUrl))
        self.imageViewBlocklist.contentMode = .scaleAspectFill
    }
}
