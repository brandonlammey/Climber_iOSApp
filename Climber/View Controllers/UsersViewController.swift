//
//  UsersViewController.swift
//  Climber
//
//  Created by Giovanni on 1/2/18.
//  Copyright © 2018 AL. All rights reserved.
//

import UIKit
import Firebase

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    var user = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUsers()
    }
    
    func retrieveUsers(){
        let ref = Database.database().reference()
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            let users = snapshot.value as! [String : AnyObject]
            self.user.removeAll()
            for(_, value) in users{
                if let uid = value["uid"] as? String{
                    if uid != Auth.auth().currentUser?.uid{
                        let userToShow = User()
                        if let fullName = value["full name"] as? String, let imagePath = value["urlToImage"] as? String {
                            userToShow.fullName = fullName
                            userToShow.imagePath = imagePath
                            userToShow.userID = uid
                            self.user.append(userToShow)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        })
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as! UserTableViewCell
        cell.userNameLabel.text = self.user[indexPath.row].fullName
        cell.userID = self.user[indexPath.row].userID
        cell.userImage.downloadImage(from: self.user[indexPath.row].imagePath!)

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.count ?? 0
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
    }

}


extension UIImageView{
    func downloadImage(from imgURL: String!) {
        let url = URLRequest(url: URL(string: imgURL)!)
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
            
        }
        
        task.resume()
    }
}
