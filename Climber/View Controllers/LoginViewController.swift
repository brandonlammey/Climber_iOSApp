//
//  LoginViewController.swift
//  Climber
//
//  Created by Giovanni on 1/2/18.
//  Copyright © 2018 AL. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: Any) {
        guard emailField.text != "", passwordField.text != "" else {return}
        
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            
            if let error = error {
                print(error.localizedDescription)
                if (error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."){
                    // create the alert
                    let alert = UIAlertController(title: "Error", message: "Email not found.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                else if (error.localizedDescription == "The password is invalid or the user does not have a password."){
                    // create the alert
                    let alert = UIAlertController(title: "Error", message: "Invalid password for  entered email.", preferredStyle: UIAlertControllerStyle.alert)
                 
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                 
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            
            if let user = user {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersViewController")
                
                self.present(vc, animated: true, completion: nil)
            }
        })
    }
}
