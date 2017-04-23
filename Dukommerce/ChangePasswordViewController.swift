//
//  ChangePasswordViewController.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/13/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ChangePasswordViewController: UIViewController {
    
    /* Change Password Storyboard Outlets */
    
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var oldPasswordLabel: UITextField!
    @IBOutlet var newPasswordLabel: UITextField!
    @IBAction func submitPasswordChange(_ sender: Any) {
        if oldPasswordLabel.text == nil || newPasswordLabel.text == nil {
            self.warningSet(warning: "Please fill in all fields.")
            return
        }
        
        let user = FIRAuth.auth()?.currentUser!
        let passwordCheck = FIREmailPasswordAuthProvider.credential(withEmail: (user?.email!)!, password: oldPasswordLabel.text!)
        user?.reauthenticate(with: passwordCheck, completion: { (error) in
            if error != nil {
                self.warningSet(warning: "Incorrect current password, please try again")
            }
            else {
                user?.updatePassword(self.newPasswordLabel.text!, completion: { (error) in
                    if error != nil {
                        self.warningSet(warning: "Error changing password, please try again")
                    }
                    else{
                        self.performSegue(withIdentifier: "showProfile", sender: self)
                    }
                })
            }
        })
    }
    
    /* Change Password Initializers */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.warningLabel.isHidden = true
    }
    
    func warningSet(warning: String){
        self.warningLabel.text = warning
        self.warningLabel.isHidden = false
    }
}
