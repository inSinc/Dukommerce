//
//  RegisterViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    var wasError: Bool = false
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet var passwordShowHideButton: UIButton!
    @IBAction func passwordShowHideButtonTouch(_ sender: Any) {
        if passwordShowHideButton.currentTitle! == "Show"{
            passwordShowHideButton.setTitle("Hide", for: UIControlState.normal)
            passwordTextField.isSecureTextEntry = false
        }
        else {
            passwordShowHideButton.setTitle("Show", for: UIControlState.normal)
            passwordTextField.isSecureTextEntry = true
        }
    }
    @IBAction func registerAction(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
            let email: String? = self.emailTextField.text
            print("\(email!.substring(from: email!.index(email!.endIndex, offsetBy: -9)))")
            if email!.substring(from: email!.index(email!.endIndex, offsetBy: -9)) != "@duke.edu"  {
                self.unableToRegister(errorMessage: "Please use an @duke.edu email address.")
                return
            }
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
                if let myError = error {
                    if let errorCode = FIRAuthErrorCode(rawValue: myError._code) {
                        switch errorCode {
                        case .errorCodeInvalidEmail:
                            self.unableToRegister(errorMessage: "Please use a valid email address.")
                        case .errorCodeEmailAlreadyInUse:
                            self.unableToRegister(errorMessage: "Email already in use, please try again.")
                        default:
                            self.unableToRegister(errorMessage: "Error creating account, please try again.")
                        }
                    }
                } else{
                    print("Successfully signed in user.")
                }
            }
            
            FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
                if user != nil {
                    print("Successfully logged in user after registration")
                    let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                    changeRequest?.displayName = self.nameTextField.text!
                    changeRequest?.commitChanges() { (error) in
                        if error != nil {
                            self.unableToRegister(errorMessage: "Error updating user name, please try again.")
                        }
                    }
                    print("Successfully updated users name.")
                    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
                    let usersRef = ref.child("users")
                    let userRef = usersRef.child(user!.uid)
                    userRef.child("posted").setValue("")
                    userRef.child("saved").setValue("")
                    userRef.child("sold").setValue("")
                    userRef.child("bought").setValue("")
                    userRef.child("ratings").setValue("")
                    userRef.child("messageSets").setValue("")
                    userRef.child("userID").setValue(user?.uid)
                    userRef.child("userName").setValue(self.nameTextField.text!)
                    userRef.child("userEmail").setValue(self.emailTextField.text!)
                    userRef.child("userImagePath").setValue("")
                    print("Successfully stored user in database.")
                    self.performSegue(withIdentifier: "showHome", sender: self)
                }
            }
        }
        else{
            self.unableToRegister(errorMessage: "Please fill in all input fields.")
        }
    }
    
    func unableToRegister(errorMessage: String){
        self.warningLabel.text = errorMessage
        print("ERROR: \(errorMessage)")
        self.warningLabel.isHidden = false
        self.wasError = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        warningLabel.isHidden = true
        passwordTextField.isSecureTextEntry = true
        let emailBottomLine = CALayer()
        emailBottomLine.frame = CGRect(x: 0.0, y: emailTextField.frame.height - 1,width: emailTextField.frame.width,height: 0.5)
        emailBottomLine.backgroundColor = UIColor.white.cgColor
        emailTextField.borderStyle = UITextBorderStyle.none
        emailTextField.layer.addSublayer(emailBottomLine)
        let passwordBottomLine = CALayer()
        passwordBottomLine.frame = CGRect(x: 0.0, y: passwordTextField.frame.height - 1,width: passwordTextField.frame.width,height: 0.5)
        passwordBottomLine.backgroundColor = UIColor.white.cgColor
        passwordTextField.borderStyle = UITextBorderStyle.none
        passwordTextField.layer.addSublayer(passwordBottomLine)
        let nameTextFieldLine = CALayer()
        nameTextFieldLine.frame = CGRect(x: 0.0, y: nameTextField.frame.height - 1,width: nameTextField.frame.width,height: 0.5)
        nameTextFieldLine.backgroundColor = UIColor.white.cgColor
        nameTextField.borderStyle = UITextBorderStyle.none
        nameTextField.layer.addSublayer(nameTextFieldLine)
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        if touches.first?.view != filterTableView {
        view.endEditing(true)
        //        }
        super.touchesBegan(touches, with: event)
    }
}

