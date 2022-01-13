//
//  DataBaseManager.swift
//  Smaher_alharthi
//
//  Created by smaher on 09/06/1443 AH.
//

import Foundation
import FirebaseDatabase
import UIKit

final class DataBaseManager{
    static let shared = DataBaseManager()
    private let db = Database.database().reference()
    static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DataBaseManager{
    public func getDataFor(path: String, completion: @escaping (Result<Any,Error>) -> Void){
        self.db.child("\(path)").observeSingleEvent(of: .value) {snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DBError.FailedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public func offLineUser(UID : String){
        self.db.child("online").child(UID).removeValue()
    }
    
    public func userExsists(with email: String, completion: @escaping((Bool) -> Void)){
        let safeEmail = DataBaseManager.safeEmail(emailAddress: email)
        
        db.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? [String:Any] != nil else{
                completion(false)// this means the email is new so go on and register it
                return
            }
            completion(true)// this means the email is already registered
        }
        
    }
    // add new user to the DB
    public func insertUser(with user : GroceryAppUser, completion: @escaping (Bool) -> Void){
        
        self.db.child("online").child(user.userId).setValue(user.emailAddress,withCompletionBlock: {error , _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    public func getAllUsers(completion: @escaping (Result<[String:String], Error>) -> Void){
        db.child("online").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [String:String] else{
                completion(.failure(DBError.FailedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public func insertItem(with item : GroceryAppItem, completion: @escaping (Bool) -> Void){
        //create new item
        let newItem: [String: Any] = [
            "addedByUser": item.addedByUser,
            "completed": item.completed,
            "name": item.name]
        
        //add user to the list of users in database
        self.db.child("grocery-item").observeSingleEvent(of: .value, with: { snapshot in
            if var groceryList = snapshot.value as? [String:[String: Any]] {
                
                
                groceryList["\(item.name)"] = newItem
                self.db.child("grocery-item").setValue(groceryList, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            else {
                
                self.db.child("grocery-item").setValue([item.name:newItem], withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
        
    }
    
    func deleteItem(with item : GroceryAppItem){
        self.db.child("grocery-item").child(item.name).removeValue()
    }
    
    public func getAllItems(completion: @escaping (Result<[String:[String:Any]], Error>) -> Void){
        db.child("grocery-item").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [String:[String:Any]] else{
                completion(.failure(DBError.FailedToFetch))
                return
            }
            completion(.success(value))
        })
    }
}

public enum DBError : Error{
    case FailedToFetch
}
struct GroceryAppUser{
    let emailAddress : String
    let userId : String
    
}
struct GroceryAppItem{
    let addedByUser : String
    let completed : Bool
    let name : String
    
}

