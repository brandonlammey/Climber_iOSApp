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
            //nextButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", password.text != "", confirmPassword.text != "" else {
            return
        }
        
        if password.text == confirmPassword.text{
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!, completion:{(user, error) in
                
                if let error = error{
                    print(error.localizedDescription)
                }
                
                if let user = user{
                    
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text!
                    changeRequest.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    
                    let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                    
                    let uploadTask = imageRef.put(data, metadata:nil, completion:{(metadata, err) in
                        if err != nil{
                            print(err!.localizedDescritption)
                        }
                        
                        imageRef.downlaodURL(completion: {(url,er) in
                            if er != nil{
                                print(er!.localizedDescription)
                            }
                            
                            if let url = url{
                                let userInfo: [String: Any] = ["uid" : user.uid, "full name": self.nameField.text!, "urlToImage" : url.absoluteString]
                                
                                //create user
                                self.ref.child("users").child(user.uid).setValue(userInfo)
                                
                                //go to user view
                                let thisView = UIStoryboard(name: "Main", bundle:nil).instantiateInitialViewController(withIdentifier: "usersViewController")
                                
                                self.present(thisView, animated:true, completion: nil)
                            }
                        })
                    })
                    
                    uploadTask.resume()
                }
                
            })
            
        }
        else{
            print("PASSWORD DOES NOT MATCH")
        }
    }
    

}
