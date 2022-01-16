//
//  UserOnlineTableViewController.swift
//  Smaher_alharthi
//
//  Created by smaher on 09/06/1443 AH.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class UserOnlineTableViewController: UITableViewController {

    
    var UsersList = [String : String]()
    var tableViewList :[String] {
        get {
            return Array(UsersList.values)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataBaseManager.shared.getAllUsers(completion: { result in
            switch result{
            case . success(let myList):
                self.UsersList = myList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case . failure(let error):
                print(error)
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UsersList.count
    }
    
    @IBAction func SignOutButtonPressed(_ sender: Any) {
        do {
            // Firebase SignOut
            let userID = Auth.auth().currentUser?.uid
            try Auth.auth().signOut()
            //Google SignOut
            GIDSignIn.sharedInstance.signOut()
            DataBaseManager.shared.offLineUser(UID: userID!)
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.removeObject(forKey: "email")
            //return to Sign in page
            self.navigationController?.popToRootViewController(animated: true)
        }
        catch { print("already logged out") }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        cell.textLabel?.text = tableViewList[indexPath.row]
        return cell
    }
}
