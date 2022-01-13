//
//  ViewController.swift
//  Smaher_alharthi
//
//  Created by smaher on 09/06/1443 AH.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class RegisterViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    //Sign in by Google Account
    @IBAction func GoogleLoginPressed(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {return}
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
        guard error == nil else {
            print("error on google auth")
            return }
            
            guard let authentication = user?.authentication,
                    let idToken = authentication.idToken else{
               return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential, completion: {result , error in
                guard let result = result?.user, let email = result.email, error == nil else{
                    print("error on google auth to firebase")
                    return
                }
                DataBaseManager.shared.userExsists(with: email, completion: {checkExists in
                    if !checkExists {
                        let User = GroceryAppUser(emailAddress: email, userId: Auth.auth().currentUser!.uid)
                        DataBaseManager.shared.insertUser(with: User, completion: {sucess in
                            if sucess{
                                print("success")
                            }
                        })
                    }
                    UserDefaults.standard.set(email, forKey: "email")
                    self.performSegue(withIdentifier: "home", sender: nil)
                })
                
                
            })
                
        }}
        
    @IBAction func RegisterButtonPressed(_ sender: Any) {
        if email.text!.isEmpty || password.text!.isEmpty || confirmPassword.text!.isEmpty {
            AlertDialog(title: "Missing Feilds", message: "Please fill all the ")
        }else if password.text != confirmPassword.text {
            AlertDialog(title: "Mismatch", message: "Passowrd and Confirm Password doesn't match ! try again ")
        }else{
            createAccount()
        }
    }
    
    func AlertDialog (title : String, message : String){
    let alert = UIAlertController(title:title, message: message,preferredStyle: .alert)

       let cancelAction = UIAlertAction(title: "ok", style: .default) {UIAlertAction -> Void in }
      
       alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAccount(){
        DataBaseManager.shared.userExsists(with: email.text!) { [weak self] exists in
            guard let strongSelf = self else{return}
            guard !exists else{
                strongSelf.showAlert(title: "Email Already Exists", message: "Looks like your email already exists , try to log in !")
                return}
            Auth.auth().createUser(withEmail: strongSelf.email.text!, password: strongSelf.password.text!) { authResult, error in
                
                if let error = error{
                    print("something went wrong \(error)")
                }else{
                    print("user \(strongSelf.email.text!) account is created successfully !")
                    
                    UserDefaults.standard.setValue(strongSelf.email.text!, forKey: "email")
                    
                    let GroceryUser = GroceryAppUser(emailAddress: strongSelf.email.text!,  userId: Auth.auth().currentUser!.uid )
                    DataBaseManager.shared.insertUser(with: GroceryUser, completion: {sucess in
                        if sucess{
                        print("user added")
                        strongSelf.performSegue(withIdentifier: "home", sender: nil)
                        }else{
                            print("user addition failed")
                        }
                    })
                    
                }
            }
        }
}
    
    func showAlert(title : String, message: String){
        let alert = UIAlertController(title:title, message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}

