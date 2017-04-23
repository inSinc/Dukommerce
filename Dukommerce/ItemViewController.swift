//
//  ItemViewController.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/2/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class ItemViewController: UIViewController {
    
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var user: FIRUser?
    var savedRef: FIRDatabaseReference?
    
    /* Item View Storyboard Outlets */
    
    @IBOutlet weak var sellerButton: UIButton!
    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var itemPrice: UILabel!
    @IBOutlet var itemCategories: UILabel!
    @IBOutlet var itemDescription: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    @IBOutlet weak var itemCondition: UILabel!
    var comingFromBuyThread: Bool?
    var comingFromOtherUserProfile: Bool?
    
    @IBAction func sellerButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "showSeller", sender: nil)
    }
    @IBAction func savedButton(_ sender: Any) {
        if saveButton.titleLabel?.text == "Save" {
//            globalUser.userSavedItems.insert(item!, at: 0)
            saveButton.setTitle("Unsave", for: UIControlState.normal)
            savedRef?.child((item?.itemID)!).setValue(item?.itemName)
        }else{
            saveButton.setTitle("Save", for: UIControlState.normal)
            savedRef?.child((item?.itemID)!).removeValue()
        }
    }
    
    @IBAction func buyAction(_ sender: Any) {
        performSegue(withIdentifier: "messageSeller", sender: nil)
    }
    
    /* Item View Properties */
    
    var item:Item?
    var feedSegue: Bool?
    
    /* Item View Initialization */
    
    override func viewDidLoad(){
        if comingFromBuyThread != nil {
            buyButton.isHidden = true
        }
        
        sellerButton.setTitle(item?.itemUserName, for: UIControlState.normal)
        itemImage.image = item!.itemImage
        itemName.text = item!.itemName
        itemPrice.text = "$\(item!.itemPrice)"
        print("Desc: \(item!.itemDescription)")
        itemDescription.text = item!.itemDescription
        itemCategories.text = item!.itemCategories.flatMap({$0.rawValue}).joined(separator: ", ")
        itemCondition.text = item?.itemCondition
        if feedSegue != nil {
            saveButton.isHidden = false
            buyButton.isHidden = false
        }
        else{
            buyButton.isHidden = true
            saveButton.isHidden = true
        }
        
        ref = FIRDatabase.database().reference()
        self.user = (FIRAuth.auth()?.currentUser)
        if item!.itemUserID == self.user?.uid {
            buyButton.isHidden = true
            saveButton.isHidden = true
        }
        let userRef = ref.child("users").child((user?.uid)!)
        savedRef = userRef.child("saved")
        savedRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild((self.item?.itemID)!) {
                self.saveButton.setTitle("Unsave", for: UIControlState.normal)
            }else{
                print("setting Unsave")
                self.saveButton.setTitle("Save", for: UIControlState.normal)
            }
        })
        //item is user's item
        if (item?.itemUserID)! == (user?.uid)! {
            buyButton.isHidden = true
        }
        
        if comingFromOtherUserProfile != nil {
            sellerButton.isHidden = true
            buyButton.isHidden = false
            saveButton.isHidden = false
        }
        
        //avoid duplicate message streams
        let messageSetsRef: FIRDatabaseReference? = userRef.child("messageSets")
        messageSetsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            let list = snapshot.value as? [String:AnyObject]
            if let messageList = list {
                for messageItem in messageList {
                    let itemDetails = messageItem.value as! [String:AnyObject]
                    let id = itemDetails["messageSetItemID"] as! String
                    if id == self.item?.itemID {
                        print("MATCH")
                        self.buyButton.setTitle("See Messages", for: UIControlState.normal)
                        self.buyButton.isUserInteractionEnabled = false
                    }
                }
            }
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "messageSeller"{
            let destination = segue.destination as! MessageDetailViewController
            destination.messageSetItemName = item?.itemName
            destination.messageSetItemID = item?.itemID
            destination.otherUserID = item?.itemUserID
            destination.otherUserName = item?.itemUserName
            destination.initialBuy = true
        }
        else if segue.identifier == "showSeller" {
            let destination = segue.destination as! ProfileViewController
            destination.otherUserID = item?.itemUserID
            destination.otherUser = true
            destination.otherUserName = item?.itemUserName
        }
    }
}
