//
//  TabBarController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 09/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.tabBar.items?[0].title = "Messages"
        self.tabBar.items?[1].title = "Contacts"
        self.tabBar.items?[2].title = "Profile"
    }
}
