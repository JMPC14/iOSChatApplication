//
//  ViewController.swift
//  FirebaseApp
//
//  Created by Jack Colley on 02/09/2020.
//  Copyright © 2020 Jack. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var isSignIn = true
    
    var imagePickerController = UIImagePickerController()

    @IBOutlet weak var signInSelector: UISegmentedControl!
    
    @IBOutlet weak var signInLabel: UILabel!
    
    @IBOutlet weak var usernameStackView: UIStackView!
        
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var imageViewNewUser: UIImageView!
    
    @IBOutlet weak var buttonChoosePicture: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if Auth.auth().currentUser != nil {
            login()
        }
        
        self.navigationController?.isNavigationBarHidden = true
        
        imageViewNewUser.isHidden = true
        buttonChoosePicture.isHidden = true
        usernameStackView.isHidden = true
    }
    
    @IBAction func choosePicturePressed(_ sender: Any) {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let image = info[.originalImage] as? UIImage {
            self.imageViewNewUser.image = image
        } else {
            print("Take another")
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    func login() {
        let uid: String? = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
            let user = try? JSONDecoder().decode(ChatUser.self, from: data)
            FirebaseManager.manager.currentUser = user!
            
            Database.database().reference(withPath: "online-users/\(user!.uid)").setValue(true)
            
            self.performSegue(withIdentifier: "goToHome", sender: self)
            
        })
    }
    
    func uploadAndSaveUser() {
        let filename = UUID.init().uuidString
        let ref = Storage.storage().reference().child("images/\(filename)")
        let uploadData = self.imageViewNewUser.image!.pngData()
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        ref.putData(uploadData!, metadata: metadata, completion: { metadata, error in
            ref.downloadURL(completion: { url, error in
                let user = ChatUserNew(
                    Auth.auth().currentUser!.uid,
                    self.usernameTextField.text!,
                    url!.absoluteString,
                    self.emailTextField.text!
                )
                let userRef = Database.database().reference().child("users")
                userRef.child(user.uid).setValue(user.toAnyObject())
                let newRef = Database.database().reference()
                newRef.child("users/\(user.uid)").observe(.value, with: { snapshot in
                    guard let data = try? JSONSerialization.data(withJSONObject: snapshot.value as Any, options: []) else { return }
                    let user = try? JSONDecoder().decode(ChatUser.self, from: data)
                    FirebaseManager.manager.currentUser = user!
                    self.performSegue(withIdentifier: "goToHome", sender: nil)
                })
            })
        })
    }
    
    @IBAction func signInSelectorChanged(_ sender: Any) {
        isSignIn = !isSignIn
        if signInSelector.selectedSegmentIndex == 0 {
            // Sign In
            signInLabel.text = "Sign In"
            signInButton.setTitle("Sign In", for: .normal)
            usernameStackView.isHidden = true
            imageViewNewUser.isHidden = true
            buttonChoosePicture.isHidden = true
        } else {
            // Register
            signInLabel.text = "Register"
            signInButton.setTitle("Register", for: .normal)
            usernameStackView.isHidden = false
            imageViewNewUser.isHidden = false
            buttonChoosePicture.isHidden = false
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        // Validation
        if let email = emailTextField.text, let pass = passwordTextField.text {
            if isSignIn {
                // Sign In
                Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: {(user, error) in
                    if user != nil {
                        // User is found
                        self.login()
                    } else {
                        // Error
                    }
                })
            } else {
                // Register
                print(email, pass)
                Auth.auth().createUser(withEmail: email, password: pass, completion: { (user, error) in
                    if user != nil {
                        // User is found
                        self.uploadAndSaveUser()
                    } else {
                        print(error!)
                        // Error
                    }
                })
            }
        }
    }
    
}

