//
//  FirebaseManager.swift
//  FirebaseApp
//
//  Created by Jack Colley on 02/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import Foundation

class FirebaseManager {
    static var manager = FirebaseManager()
    
    var currentUser: ChatUser
    var otherUser: ChatUser
    var onlineUsers: [String]
    var cid: String
    var latestMessageSeen: String
    
    init() {
        self.currentUser = ChatUser()
        self.otherUser = ChatUser()
        self.onlineUsers = [String]()
        self.cid = String()
        self.latestMessageSeen = String()
    }
}
