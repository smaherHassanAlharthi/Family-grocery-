//
//  LoginViewController.swift
//  Smaher_alharthi
//
//  Created by smaher on 10/06/1443 AH.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    private let spinner = JGProgressHUD(style: .dark)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func showAlert(title : String, message: String){
        let alert = UIAlertController(title:title, message: message , preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        loginAccount()
    }
    func loginAccount(){
        loginEmail.resignFirstResponder()
        loginPassword.resignFirstResponder()
        guard let email = loginEmail.text, let password = loginPassword.text,
              !email.isEmpty , !password.isEmpty , password.count >= 6 else{
                  self.showAlert(title: "Oops", message: "Please Fill In All The Feilds To Login !")
                  return
              }
        spinner.show(in: view)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else{
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else{
                self!.showAlert(title: "Oops", message: "This Email dosen't exists , try to register !")
                print("failed to login with email \(email)")
                return
            }
            
            let user = result.user
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("logged in user \(user) ")
            strongSelf.performSegue(withIdentifier: "home", sender: nil)
            
            
        }
    }
    
    
    
}
