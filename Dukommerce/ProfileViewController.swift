//
//  ProfileViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 3/29/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /* Profile Storyboard Outlets */
    
    @IBOutlet var userItemCollectionView: UICollectionView!

    @IBOutlet weak var profileImage: UIButton!
    @IBOutlet var userName: UILabel!

    
    @IBAction func profileImageButton(_ sender: Any) {
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
    
    /* Profile Properties */
    
    var selectedRow: Int = 0
    var user: FIRUser?
    var otherUserID: String?
    var otherUserName: String?
    var otherUser: Bool?
    var userRef: FIRDatabaseReference?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var postedItems: [Item] = []
    var postedRef: FIRDatabaseReference?
    var imagePicker = UIImagePickerController()
    var selectedImage = UIImage()
    var imageUploaded = false
    var storage: FIRStorage?
    var storageRef: FIRStorageReference?
    
    /* Profile View Management */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        imagePicker.delegate = self
        storage = FIRStorage.storage()
        storageRef = storage?.reference()
        self.user = (FIRAuth.auth()?.currentUser)
        if otherUser != nil {
            //print("     VIEWING AS OTHER USER")
            userRef = ref.child("users").child(otherUserID!)
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.leftBarButtonItems = nil
            self.userName.text = otherUserName!
            self.profileImage.isUserInteractionEnabled = false
        }else{
            userRef = ref.child("users").child((user?.uid)!)
            self.userName.text = user!.displayName!
        }
        self.postedRef = userRef?.child("posted")
        
        postedRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSDictionary) {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        })
        //let itemsRef = ref.child("items")
        let itemsRef = self.ref.child("items")
        postedRef?.observe(.childAdded, with: { (snapshot) in
            let postedItemID = snapshot.key
            itemsRef.child(postedItemID).observeSingleEvent(of: .value, with: { (snapshot) in
                let postedItem = Item(snapshot: snapshot)
                let item = snapshot.value as! [String:AnyObject]
                postedItem.itemImagePath = item["itemImagePath"] as! String
                postedItem.downloadImage(completionHandler: { (done) in
                    if done {
                        print("     DONE LOADING IMAGE")
                        self.postedItems.insert(postedItem, at: 0)
                        activityIndicator.stopAnimating()
                        activityIndicator.isHidden = true
                        self.userItemCollectionView.reloadData()
                    }
                })

            })
        })
        postedRef?.observe(.childChanged, with: { (snapshot) in
            let postedItemID = snapshot.key
            print("     CHANGED: \(postedItemID)")
            itemsRef.child(postedItemID).observeSingleEvent(of: .value, with: { (snapshot) in
                let newItem = Item(snapshot: snapshot)
                for (itemNum, item) in self.postedItems.enumerated() {
                    if item.itemID == postedItemID {
                        newItem.downloadImage(completionHandler: { (done) in
                            if done {
                                self.postedItems[itemNum] = newItem
                                self.userItemCollectionView.reloadData()
                            }
                        })
                        break
                    }
                }
            })
        })
        postedRef?.observe(.childRemoved, with: { (snapshot) in
            let itemID:String = snapshot.key
            for i in 0...self.postedItems.count-1{
                if self.postedItems[i].itemID == itemID {
                    self.postedItems.remove(at: i)
                    self.userItemCollectionView.reloadData()
                    break
                }
            }
        })
        itemsRef.observe(.childChanged, with: { (snapshot) in
            let itemID:String = snapshot.key
            let itemDictionary = snapshot.value as! [String:AnyObject]
            let itemImagePath = itemDictionary["itemImagePath"] as! String
            let changedItem = Item(snapshot: snapshot)
            for (itemNum, item) in self.postedItems.enumerated() {
                if item.itemID == itemID {
                    item.itemImagePath = itemImagePath
                    item.downloadImage(completionHandler: { (done) in
                        self.postedItems[itemNum] = changedItem
                        self.userItemCollectionView.reloadData()
                    })
                    break
                }
            }
        })
        
        profileImage.setImage(UIImage(named: "DefaultProfilePic"), for: UIControlState.normal)
        var userImagePath = ""
        self.userRef?.child("userImagePath").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil && snapshot.value as! String != "" {
                userImagePath = (snapshot.value)! as! String
                //print("user image path set to: ",userImagePath)
                self.downloadProfileImage(itemImagePath: userImagePath)
            }
        })
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionLayout.itemSize = CGSize(width: 120, height: 140)
        userItemCollectionView!.dataSource = self
        userItemCollectionView!.delegate = self
        userItemCollectionView!.collectionViewLayout = collectionLayout
        profileImage.layer.cornerRadius = 4
        self.userItemCollectionView.reloadData()
    }
    
    func uploadProfileImage(image: UIImage){
        let imageData = UIImageJPEGRepresentation(image, 0.05)
        let userID:String = (user?.uid)!
        let imageReference = storageRef?.child("userImages/\(userID)")
        _ = imageReference?.put(imageData!, metadata: nil, completion: { (metadata, error) in
            if error == nil {
                self.userRef?.child("userImagePath").setValue("userImages/\(userID)")
            }else{
                self.profileImage.setImage(UIImage(named: "DefaultProfilePic"), for: UIControlState.normal)
                let alert = UIAlertController(title: "Uploading error", message: "Please try again.", preferredStyle: UIAlertControllerStyle.alert)
                let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func downloadProfileImage(itemImagePath: String) {
        print("Downloading from: \(itemImagePath)")
        let imageDownloadPath = storageRef?.child(itemImagePath)
        imageDownloadPath?.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                //Error dang:/
                let image = UIImage(named: "DefaultProfilePic")!
                self.profileImage.setImage(image, for: UIControlState.normal)
                print("Error downloading image.")
            } else {
                print("image successfully downloaded")
                let image = UIImage(data: data!)!
                self.profileImage.setImage(image, for: UIControlState.normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Profile View Collection Methods */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userItemCollectionView!.dequeueReusableCell(withReuseIdentifier: "itemCollectionCell", for: indexPath) as! ItemCollectionViewCell
        cell.itemName.text = postedItems[indexPath.row].itemName
        let cellLayer : CALayer? = cell.itemImage.layer
        cellLayer!.cornerRadius = 4
        cellLayer!.masksToBounds = true
        cell.itemImage.image = postedItems[indexPath.row].itemImage
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        if otherUser != nil {
            performSegue(withIdentifier: "showItem", sender: self)
        }else{
            performSegue(withIdentifier: "editItem", sender: self)
        }
    }
    
    /*Image Picker Delegate functions*/
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {        imageUploaded = true
        selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true)
        profileImage.setImage(selectedImage, for: UIControlState.normal)
        uploadProfileImage(image: selectedImage)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    /* Profile View Segue Management */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let destination = segue.destination as? ItemViewController {
                destination.item = postedItems[selectedRow]
                destination.comingFromOtherUserProfile = true
            }
        } else if segue.identifier == "showLogin" {
            do {
                try FIRAuth.auth()?.signOut()
            } catch {
                print("Error: Unable to sign out current user.")
            }
            print("Successfully signed out current user")
        } else if segue.identifier == "editItem" {
            if let destination = segue.destination as? AddViewController {
                destination.editItemSegue = true
                destination.editItem = self.postedItems[selectedRow]
            }
        }
    }
    
    @IBAction func unwindToProfile(segue: UIStoryboardSegue){
        if segue.identifier == "editItem" {
            if let source = segue.source as? AddViewController {
                source.editItemSegue = false
                self.userItemCollectionView.reloadData()
            }
        }
    }
}
