//
//  LoginViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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
    
    @IBAction func loginAction(_ sender: Any) {
        let email: String? = self.emailTextField.text
        if email == nil || self.passwordTextField.text == nil {
            self.setWarningLabel(warning: "Please fill out all fields.")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: self.passwordTextField.text!){ (user, error) in
            if let myError = error {
                if let errorCode = FIRAuthErrorCode(rawValue: myError._code) {
                    switch errorCode {
                    case .errorCodeUserNotFound:
                        self.setWarningLabel(warning: "Error signing in, could not find user.")
                    case .errorCodeWrongPassword:
                        self.setWarningLabel(warning: "Incorrect password, please try again.")
                    default:
                        self.setWarningLabel(warning: "Error signing in to account, please try again.")
                    }
                }
            }
            else{
                self.performSegue(withIdentifier: "segueToHome", sender: self)
            }
        }
    }
    
    func setWarningLabel(warning: String){
        self.warningLabel.text = warning
        print(warning)
        self.warningLabel.isHidden = false
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
