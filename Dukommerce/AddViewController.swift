//
//  AddViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 3/29/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    /*Class Variables*/
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    
    @IBOutlet weak var itemDescription: UITextField!
    @IBOutlet weak var itemCategory: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var itemCondition: UISegmentedControl!
    @IBAction func deleteItemSegue(_ sender: Any) {
        let itemRef = ref.child("items")
        itemRef.child(editItem.itemID).removeValue(completionBlock: { (error, refer) in
            if error != nil {
                self.alertLabel.isHidden = false
                self.alertLabel.text = "Error deleting item from items, please try again."
                return
            } else {
                let postedRef = self.ref.child("users").child(self.user!.uid).child("posted")
                postedRef.child(self.editItem.itemID).removeValue(completionBlock: { (error, refer) in
                    if error != nil {
                        self.alertLabel.isHidden = false
                        self.alertLabel.text = "Error deleting item from posted items."
                        return
                    } else {
                        let mainRef = self.ref.child("mainFeed")
                        mainRef.child(self.editItem.itemID).removeValue(completionBlock: { (error, refer) in
                            if error != nil {
                                self.alertLabel.isHidden = false
                                self.alertLabel.text = "Error deleting item from main."
                                return
                            } else {
                                self.storageRef?.child(self.editItem.itemImagePath).delete(completion: { (error) in
                                    if error != nil {
                                        self.alertLabel.isHidden = false
                                        self.alertLabel.text = "Error deleting item picture."
                                        return
                                    } else {
                                        self.editItemSegue = false
                                        self.performSegue(withIdentifier: "unwindToProfile", sender: self)
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    @IBOutlet var deleteItem: UIButton!
    
    //var firebaseRef: FIRDatabaseReference!
    var imageUploaded: Bool = false
    var categoriesSelected: Bool = false
    var editItemSegue: Bool?
    var editItem: Item!
    var newItem: Item!
    var imagePicker = UIImagePickerController()
    var selectedImage = UIImage()
    var categories: [Item.ItemCategories]!
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var user: FIRUser?
    var storage: FIRStorage?
    var storageRef: FIRStorageReference?
    var postedRef: FIRDatabaseReference?
    var activeTextView: UITextView?
    
    /* Upload Image with Action Sheet */
    
    @IBAction func uploadImageAction(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Please select a photo source.", preferredStyle: UIAlertControllerStyle.actionSheet)
        let libraryAction = UIAlertAction(title: "Library", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePictureAction = UIAlertAction(title: "Take Picture", style: UIAlertActionStyle.default, handler: {
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.availableCaptureModes(for: UIImagePickerControllerCameraDevice.rear) != nil {
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
                self.imagePicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }else{
                let alert = UIAlertController(title: "Alert!", message: "No rear camera found.", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: {
                    optionMenu.dismiss(animated: true, completion: nil)
                })
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(takePictureAction)
        optionMenu.addAction(libraryAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    /* Upload item once upload button pressed */
    
    @IBAction func uploadItem(_ sender: Any) {
        print(itemCondition.selectedSegmentIndex)
        if !imageUploaded || !categoriesSelected || itemCondition.selectedSegmentIndex < 0 {
            alertLabel.isHidden = false
            alertLabel.text = "Please enter all data."
            return
        }
        if itemTitle.text == nil || itemPrice.text == nil || itemDescription.text == nil {
            alertLabel.isHidden = false
            alertLabel.text = "Please fill in all fields"
            print("secondcheck return")
            return
        }
        var itemStatus: Item.ItemStatus
        var date: String
        var itemID: String
        let mainref = ref.child("mainFeed").childByAutoId()
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, hh:mm"
        if let editItemBool = editItemSegue {
            itemStatus = editItemBool ? editItem.itemStatus : Item.ItemStatus.NewItem
            date = editItemBool ? editItem.itemPostedDate : dateFormatter.string(from: Date())
            itemID = editItemBool ? editItem.itemID : mainref.key
        }
        else {
            itemStatus = Item.ItemStatus.NewItem
            date = dateFormatter.string(from: Date())
            itemID = mainref.key
        }
        user = FIRAuth.auth()?.currentUser!

        //image data conversion & we uploading up in here
        let imageData = UIImageJPEGRepresentation(uploadImageButton.image(for: UIControlState.normal)!, 0.1)
        let imageReference = storageRef?.child("itemImages/\(itemID)")
        let _ = imageReference?.put(imageData!, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                print("image uploaded successfully")
                self.ref.child("items").child(itemID).child("itemImagePath").setValue("itemImages/\(itemID)")
                self.newItem = Item(itemUserName: self.user!.displayName!, itemUserID: self.user!.uid, itemName: self.itemTitle.text!, itemPrice: Double(self.itemPrice.text!)!, itemCondition: self.itemCondition.titleForSegment(at: self.itemCondition.selectedSegmentIndex)!, itemStatus: itemStatus, itemDescription: self.itemDescription.text!, itemCategories: self.categories, itemDate:  date, itemID: itemID, itemImagePath: "itemImages/\(itemID)")
                let itemDict = self.newItem.itemToDict()
                self.ref.child("users").child(self.user!.uid).child("posted").child(itemID).setValue(self.newItem.itemName)
                self.ref.child("items").child(itemID).setValue(itemDict)
                print(self.ref.child("items").child(itemID))
                if let editItemBool = self.editItemSegue {
                    if editItemBool == false {
                        mainref.setValue(self.user!.uid)
                    }
                }
                else {
                    mainref.setValue(self.user!.uid)
                }
                self.clearAllFields()
                if let editItemBool = self.editItemSegue {
                    if editItemBool == false {
                        self.performSegue(withIdentifier: "unwindToFeed", sender: self)
                    }
                    else {
                        self.performSegue(withIdentifier: "unwindToProfile", sender: self)
                    }
                }
                else {
                    self.performSegue(withIdentifier: "unwindToFeed", sender: self)
                }
            }else{
                let alert = UIAlertController(title: "Uploading error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                return
            }
        })
    }
    
    func clearAllFields(){
        uploadImageButton.setImage(UIImage(named: "UploadImage.png"), for: UIControlState.normal)
        itemTitle.text = ""
        itemPrice.text = ""
        itemDescription.text = ""
        itemCategory.setTitle("Select category", for: UIControlState.normal)
        itemCondition.selectedSegmentIndex = -1
        alertLabel.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = FIRAuth.auth()?.currentUser!
        storage = FIRStorage.storage()
        storageRef = storage?.reference()
        itemPrice.delegate = self
        itemTitle.delegate = self
        itemDescription.delegate = self
        if let editItemBool = editItemSegue {
            if editItemBool == true {
                deleteItem.isHidden = false
                itemTitle.text = editItem.itemName
                itemPrice.text = String(editItem.itemPrice)
                switch editItem.itemCondition {
                case "Poor":
                    itemCondition.selectedSegmentIndex = 0
                case "Used":
                    itemCondition.selectedSegmentIndex = 1
                case "Good":
                    itemCondition.selectedSegmentIndex = 2
                case "Great":
                    itemCondition.selectedSegmentIndex = 3
                default:
                    itemCondition.selectedSegmentIndex = 4
                }
                itemDescription.text = editItem.itemDescription
                categories = editItem.itemCategories
                let categoriesString = categories.flatMap({$0.rawValue}).joined(separator: ", ")
                itemCategory.setTitle(categoriesString, for: UIControlState.normal)
                categoriesSelected = true
                uploadImageButton.setImage(editItem.itemImage, for: UIControlState.normal)
                imageUploaded = true
            }
            else {
                deleteItem.isHidden = true
            }
        } else {
            deleteItem.isHidden = true
        }
        print("User reference: ",ref.child("users"))
        print("User id: \(user!.uid)")
        print(ref.child("users").child(user!.uid))
        print(ref.child("users").child(user!.uid).child("posted"))
        alertLabel.isHidden = true
        self.imagePicker.delegate = self
        self.itemDescription.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        uploadImageButton.layer.cornerRadius = 4
        let itemNameBottomLayer = CALayer()
        itemNameBottomLayer.frame = CGRect(x: 0.0, y: itemTitle.frame.height - 1,width: itemTitle.frame.width,height: 0.5)
        itemNameBottomLayer.backgroundColor = UIColor.white.cgColor
        itemTitle.borderStyle = UITextBorderStyle.none
        itemTitle.layer.addSublayer(itemNameBottomLayer)
        let itemPriceBottomLayer = CALayer()
        itemPriceBottomLayer.frame = CGRect(x: 0.0, y: itemPrice.frame.height - 1,width: itemPrice.frame.width,height: 0.5)
        itemPriceBottomLayer.backgroundColor = UIColor.white.cgColor
        itemPrice.borderStyle = UITextBorderStyle.none
        itemPrice.layer.addSublayer(itemPriceBottomLayer)
        let itemDescriptionBottomLayer = CALayer()
        itemDescriptionBottomLayer.frame = CGRect(x: 0.0, y: itemDescription.frame.height - 1,width: itemDescription.frame.width,height: 0.5)
        itemDescriptionBottomLayer.backgroundColor = UIColor.white.cgColor
        itemDescription.borderStyle = UITextBorderStyle.none
        itemDescription.layer.addSublayer(itemDescriptionBottomLayer)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Segues*/
    @IBAction func unwindToAdd(segue: UIStoryboardSegue){
        let source = segue.source as? SelectCategoryViewController
        let selectedCategories: [Item.ItemCategories] = source?.selectedCategories as [Item.ItemCategories]!
        categories = selectedCategories
        let categoriesString = selectedCategories.flatMap({$0.rawValue}).joined(separator: ", ")
        itemCategory.setTitle(categoriesString, for: UIControlState.normal)
        categoriesSelected = true
    }
    
    /*Image Picker Delegate functions*/
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {        imageUploaded = true
        selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true)
        uploadImageButton.setImage(selectedImage, for: UIControlState.normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    /* Add View Keyboard Management */
    
    var labelCovered: Bool = false
    var viewY: CGFloat = 0
    func keyboardDidShow(notification:NSNotification){
        if self.activeTextView != nil {
            labelCovered = true
            viewY = self.view.frame.origin.y
            self.view.frame.origin.y -= 150
        }
    }
    
    func keyboardWillHide(notification:NSNotification){
        if labelCovered {
            self.view.frame.origin.y = viewY
            labelCovered = false
        }
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeTextView = nil
        view.endEditing(true)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
