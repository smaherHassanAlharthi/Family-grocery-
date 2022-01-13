//
//  GroceryItemTableViewController.swift
//  Smaher_alharthi
//
//  Created by smaher on 09/06/1443 AH.
//

import UIKit
import CloudKit

class GroceryItemTableViewController: UITableViewController {

    var groceryItems = [GroceryAppItem]()
    @IBOutlet weak var usersCounter: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllUsersCount()
        getAllItems()
    }
    
    
    func getAllItems(){
        DataBaseManager.shared.getAllItems(completion: {[weak self] result in
            switch result {
            case .success(let itemList):
                DispatchQueue.main.async {
                    self?.groceryItems.removeAll()
                    for (key, value) in itemList {
                        print(key)
                        print(value)
                        self?.groceryItems.append(GroceryAppItem(addedByUser: value["addedByUser"] as! String, completed: false, name: key))
                        self?.tableView.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
               
            }
        })
    }
    
    func getAllUsersCount(){
        DataBaseManager.shared.getAllUsers(completion: {[weak self] result in
            switch result {
            case .success(let onlineUsers):
                DispatchQueue.main.async {
                    self?.usersCounter.title = "\(onlineUsers.count)"
                    print("my count is \(onlineUsers.count)")
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func AddItemPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item",preferredStyle: .alert)
        
               let saveAction = UIAlertAction(title: "Save", style: .default)
               {
                   _ in let textField = alert.textFields![0]
                   print("the user entered: \( textField.text!)")
                   
                   guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String else{
                       return
                   }
                   //handle adding item in here
                   DataBaseManager.shared.insertItem(with: GroceryAppItem(addedByUser: currentUser, completed: false, name: textField.text ?? "")) { success in
                       if success {
                           print("item added successfully!")
                       }
                       else{
                           print("failed to add item")
                       }
                   }
                
               }
               
               let cancelAction = UIAlertAction(title: "Cancel", style: .default) {UIAlertAction -> Void in }
               alert.addTextField { UITextField -> Void in }
               alert.addAction(saveAction)
               alert.addAction(cancelAction)
               self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title : String, message: String){
        let alert = UIAlertController(title:title, message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groceryItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryItemCell", for: indexPath)
        cell.textLabel?.text = groceryItems[indexPath.row].name
        cell.detailTextLabel?.text = groceryItems[indexPath.row].addedByUser

        return cell
    }
  
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
  
        DataBaseManager.shared.deleteItem(with: groceryItems[indexPath.row])
        groceryItems.remove(at: indexPath.row)
        tableView.reloadData()
    }

}
