//
//  SignupViewController.swift
//  Climber
//
//  Created by Archer on 1/1/18.
//  Copyright © 2018 AL. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage: StorageReference!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://climber-ffb00.appspot.com")
        
        ref = Database.database().reference()
        userStorage = storage.child("users")
    }

    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.imageView.image = image
            nextButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", password.text != "", confirmPassword.text != "" else {
            // create the alert
            let alert = UIAlertController(title: "Error", message: "All fields are mandatory!", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        if password.text == confirmPassword.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!, completion: { (user, error) in
                
                if let error = error{
                    print(error.localizedDescription)
                    if (error.localizedDescription == "The email address is already in use by another account."){
                        // create the alert
                        let alert = UIAlertController(title: "Error", message: "The email address is already in use by another account.", preferredStyle: UIAlertControllerStyle.alert)
                    
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                if let user = user{
                    
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if err != nil {
                            print(err!.localizedDescription)
                        }
                        
                        imageRef.downloadURL(completion: {(url,er) in
                            if er != nil{
                                print(er!.localizedDescription)
                            }
                            
                            
                            if let url = url {
                                let userInfo: [String : Any] = ["uid" : user.uid,
                                                                "full name" : self.nameField.text!,
                                                                "urlToImage" : url.absoluteString]
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                //go to user view
                                let thisView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersViewController")
                                
                                self.present(thisView, animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                    })
                    
                    uploadTask.resume()
                    
                }
                
                
            })

            
        }
        else {
            print("PASSWORD DOES NOT MATCH")
            
            //Obtained from https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift/33340757#33340757http://musamexico.org
            // create the alert
            let alert = UIAlertController(title: "Error", message: "Passwords do not Match.", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
   
    }
    
}
