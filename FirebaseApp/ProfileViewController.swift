//
//  SettingsViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 08/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit
import FirebaseUI
import Firebase

class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var textViewUsername: UILabel!
    
    @IBOutlet weak var textViewEmail: UILabel!
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textViewUsername.text = FirebaseManager.manager.currentUser.username
        self.textViewEmail.text = FirebaseManager.manager.currentUser.email
        let ref = Storage.storage().reference(forURL: FirebaseManager.manager.currentUser.profileImageUrl)
        self.imageViewProfile.sd_setImage(with: ref)
        self.imageViewProfile.contentMode = .scaleAspectFill
    }
}
