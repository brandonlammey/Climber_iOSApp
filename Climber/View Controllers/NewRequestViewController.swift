//
//  NewRequestViewController.swift
//  Climber
//
//  Created by Giovanni on 1/3/18.
//  Copyright © 2018 AL. All rights reserved.
//

import UIKit
import Firebase

class NewRequestViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var selectImage: UIButton!
    @IBOutlet weak var daysLookingText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var detailsText: UITextView!
    @IBOutlet weak var privacyChoice: UISegmentedControl!
    
    //Initialize picker:
    var picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        
        //Add a border to detailsText. Adapted from https://www.richardhsu.me/posts/2015/01/17/textview-border.html
        var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        detailsText.layer.borderWidth = 0.5
        detailsText.layer.borderColor = borderColor.cgColor
        detailsText.layer.cornerRadius = 5.0
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.previewImage.image = image
            selectImage.isHidden = true
            requestButton.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func selectImagePressed(_ sender: Any) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func requestButtonPressed(_ sender: Any) {
        let uid = Auth.auth().currentUser!.uid
        let ref = Database.database().reference()
        let storage = Storage.storage().reference(forURL: "gs://climber-ffb00.appspot.com")
        
        let key = ref.child("posts").childByAutoId().key
        let imageRef = storage.child("posts").child(uid).child("\(key).jpg") //add another one after this
        
        let data = UIImageJPEGRepresentation(self.previewImage.image!, 0.6)
        
        let uploadTask = imageRef.putData(data!, metadata: nil){(metadata, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            imageRef.downloadURL(completion: { (url, error) in
                if let url = url {
                    let feed = ["userID" : uid,
                                "pathToImage" : url.absoluteString,
                                "likes" : 0,
                                "author" : Auth.auth().currentUser!.displayName!,
                                "postID" : key,
                                "privacy" : self.privacyChoice.titleForSegment(at: self.privacyChoice.selectedSegmentIndex)!,
                                "days" : self.daysLookingText.text!,
                                "location" : self.locationText.text!,
                                "details" : self.detailsText.text!] as [String : Any]
                    
                    let postFeed = ["\(key)" : feed]
                    
                    ref.child("posts").updateChildValues(postFeed) //to not delete previous posts
                    //AppDelegate.instance().dismissActivityIndicatos()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        uploadTask.resume()
    }
}
