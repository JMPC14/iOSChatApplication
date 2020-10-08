//
//  ComposeViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 02/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import UIKit
import Firebase

class ComposeViewController: UIViewController {
    
    var ref:DatabaseReference!
    
    @IBOutlet weak var textViewCompose: UITextView!
    
    @IBAction func addPost(_ sender: Any) {
        // Post data to Firebase
        // Dismiss popover
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelPost(_ sender: Any) {
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
