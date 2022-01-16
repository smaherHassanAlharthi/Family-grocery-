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
    
    //git all Grocery Item
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
    //git all Users Online in Count
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
    
    //Add new Grocery Item
    @IBAction func AddItemPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item",preferredStyle: .alert)
        
               let saveAction = UIAlertAction(title: "Save", style: .default)
               {
                   _ in let textField = alert.textFields![0]
                   print("the user entered: \( textField.text!)")
                   guard let currentUser = UserDefaults.standard.value(forKey: "email") as? String else{
                       return
                   }
                   //adding item
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
    
        //editing Grocery Item
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let edit = UIContextualAction(style: .normal, title: "Edit") { (contextualAction, view, actionPerformed: (Bool) -> ()) in
                
                //alert action to Edit to table view
                let Editalert = UIAlertController(
                    title: "Grocery Item",
                    message: "Edit Item",
                    preferredStyle: .alert)
                
                //save button
                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    guard
                        let textField = Editalert.textFields?.first,
                        let text = textField.text
                            
                    else { return }
                    
                    
                    //replace unaccepted string in firebase
                    var saveTxt = text.replacingOccurrences(of: ".", with: "-")
                    print("without dot\(saveTxt)")
                          saveTxt = saveTxt.replacingOccurrences(of: ",", with: "-")
                          saveTxt = saveTxt.replacingOccurrences(of: "[", with: "-")
                          saveTxt = saveTxt.replacingOccurrences(of: "]", with: "-")
                          saveTxt = saveTxt.replacingOccurrences(of: "#", with: "-")
                          saveTxt = saveTxt.replacingOccurrences(of: "$", with: "-")
                    saveTxt = saveTxt.replacingOccurrences(of: " ", with: "-")
                    
                    //deleting Grocery Item
                    let mynewItem: [String: Any] = [
                        "addedByUser": self.groceryItems[indexPath.row].addedByUser ,
                        "completed": self.groceryItems[indexPath.row].completed,
                                "name": saveTxt]
                    if saveTxt != self.groceryItems[indexPath.row].name{
                        DataBaseManager.shared.deleteItem(with: self.groceryItems[indexPath.row] )
                       
                        //again adding Grocery Item
                        DataBaseManager.shared.insertItem(with: GroceryAppItem(addedByUser: self.groceryItems[indexPath.row].addedByUser , completed: self.groceryItems[indexPath.row].completed, name: saveTxt )) { success in
                            if success {
                                print("item added successfully!")
                            }
                            else{
                                print("failed to add item")
                            }
                        }
                    }
                    else{
                        DataBaseManager.shared.db.child("grocery-item").child(self.groceryItems[indexPath.row].name).setValue(mynewItem)
                    }
                    
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                    
                }
                //cancel button
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                    style: .cancel)
                
                Editalert.addTextField()
                Editalert.addAction(saveAction)
                Editalert.addAction(cancelAction)
                self.present(Editalert, animated: true, completion: nil)
            }
            //edit button color
            edit.backgroundColor = .systemGreen
            return UISwipeActionsConfiguration(actions: [edit])
        }
    
    
    
    func showAlert(title : String, message: String){
        let alert = UIAlertController(title:title, message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // warning Incomplete implementation, return the number of rows
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
    
    
    //Checkbox completed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let groceryItem = groceryItems[indexPath.row]
        let completedItem = !groceryItem.completed
        Checkbox(cell, isCompleted: completedItem)
        
        let mynewItem: [String: Any] = [
            "addedByUser": groceryItems[indexPath.row].addedByUser ,
            "completed": completedItem,
            "name":groceryItems[indexPath.row].name ]
        DataBaseManager.shared.db.child("grocery-item").child(self.groceryItems[indexPath.row].name).setValue(mynewItem)
    }
    
    //styling checkbox
    func Checkbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
        } else {
            //changing cell color after adding checkbox
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .systemGreen
            cell.detailTextLabel?.textColor = .systemGreen
        }
    }
}
