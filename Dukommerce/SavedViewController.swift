//
//  SavedViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 3/29/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /*Class Variables*/
    @IBOutlet weak var savedTableView: UITableView!
    

    var savedItems: [Item]!
    var searchStream = [Item]()
    var searchMode = false
    var selectedRow:Int = 0
    var searchTerm = ""
    
    var user: FIRUser?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var postedItems: [Item] = []
    var postedRef: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        savedItems = []
        ref = FIRDatabase.database().reference()
        self.user = (FIRAuth.auth()?.currentUser)
        let userRef = ref.child("users").child((user?.uid)!)
        let userSaved = userRef.child("saved")
        userSaved.observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSDictionary) {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        })
        //let itemsRef = ref.child("items")
        ref = FIRDatabase.database().reference()
        userSaved.observe(.childAdded, with: { (snapshot) in
            let savedItemID = snapshot.key
            print(savedItemID)
            for item in feedStream {
                print("\(savedItemID) \(item.itemID)")
                if item.itemID == savedItemID {
                    self.savedItems.insert(item, at: 0)
                    self.savedTableView.reloadData()
                    activityIndicator.stopAnimating()
                    activityIndicator.isHidden = true
                    break
                }
            }
        })
        
        userSaved.observe(.childRemoved, with: { (snapshot) in
            let removedItemID = snapshot.key
            for i in 0...self.savedItems.count-1 {
                if self.savedItems[i].itemID == removedItemID {
                    self.savedItems.remove(at: i)
                    self.savedTableView.reloadData()
                    break
                }
            }

        })
        let itemsRef = ref.child("items")
        itemsRef.observe(.childChanged, with: { (snapshot) in
            let itemID = snapshot.key
            for (itemNum, item) in self.savedItems.enumerated() {
                if item.itemID == itemID {
                    let changedItem = Item(snapshot: snapshot)
                    changedItem.downloadImage(completionHandler: { (done) in
                        self.savedItems[itemNum] = changedItem
                        self.savedTableView.reloadData()
                    })
                }
            }
        })
        itemsRef.observe(.childRemoved, with: { (snapshot) in
            let itemID = snapshot.key
            for (itemNum, item) in self.savedItems.enumerated() {
                if item.itemID == itemID {
                    self.savedItems.remove(at: itemNum)
                    self.savedTableView.reloadData()
                }
            }
        })
        let mainRef = ref.child("mainFeed")
        mainRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            let itemID:String = snapshot.key
            //let feedItemUserID:String = snapshot.value as! String
            for (itemNum, item) in self.savedItems.enumerated() {
                if item.itemID == itemID {
                    self.savedItems.remove(at: itemNum)
                    self.savedTableView.reloadData()
                }
            }

        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savedTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*Segues*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("entering segue prep")
        if segue.identifier == "showItem" {
            if let destination = segue.destination as? ItemViewController {
                destination.item = savedItems[selectedRow]
                destination.feedSegue = true
            }
        }
    }
    
    /* Saved Table View Delegate Methods */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchMode {
            return searchStream.count
        }else{
            return savedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        print("about to segue to detailview")
        performSegue(withIdentifier: "showItem", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedTableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemTableViewCell
        if searchMode {
            cell.itemTitle.text = searchStream[indexPath.row].itemName
            cell.itemPrice.text = "$\(searchStream[indexPath.row].itemCost())"
            cell.itemAuthorWithRating.text = "from \(searchStream[indexPath.row].itemUserID)"
            let cellLayer : CALayer? = cell.itemImage.layer
            cellLayer!.cornerRadius = 4
            cellLayer!.masksToBounds = true
            cell.itemImage.image = searchStream[indexPath.row].itemImage
            if searchStream[indexPath.row].itemCategories.count > 0{
                cell.category.text = searchStream[indexPath.row].itemCategories.flatMap({$0.rawValue}).joined(separator: ", ")
            }
            else{
                cell.category.text = "None"
            }
        }else {
            cell.itemTitle.text = savedItems[indexPath.row].itemName
            cell.itemPrice.text = "$\(savedItems[indexPath.row].itemCost())"
            cell.itemAuthorWithRating.text = "from \(savedItems[indexPath.row].itemUserName)"
            let cellLayer : CALayer? = cell.itemImage.layer
            cellLayer!.cornerRadius = 4
            cellLayer!.masksToBounds = true
            cell.itemImage.image = savedItems[indexPath.row].itemImage
            if savedItems[indexPath.row].itemCategories.count > 0 {
                cell.category.text = savedItems[indexPath.row].itemCategories.flatMap({$0.rawValue}).joined(separator: ", ")
            }
            else{
                cell.category.text = "None"
            }
        }
        return cell
    }
}
