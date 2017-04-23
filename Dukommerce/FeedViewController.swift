//
//  FeedViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 3/29/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

var globalFeedTableView: UITableView!
var feedStream: [Item]!
var messageCount: Int = 0

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    /*Firebase Variables*/
    //var firebaseRef: FIRDatabaseReference!
    
    /* TODO:
        - Fix/figure out searching while filtered
    */
    
    /* Feed View Storyboard Outlets */
    
    @IBOutlet var feedSearchBar: UISearchBar!
    @IBOutlet weak var feedTableView: UITableView!
    @IBOutlet var clearFilterButton: UIButton!
    @IBAction func clearFilter(_ sender: Any) {
        clearFilterButton.isHidden = true
        filtered = false
        filterStream = []
        feedTableView.reloadData()
    }
    
    /* Feed View Properties */
    
    var selectedRow:Int = 0
    var searchMode = false
    var searchTerm = ""
    var searchStream = [Item]()
    var filtered: Bool = false
    var filterCategories: [Item.ItemCategories] = []
    var filterStream = [Item]()
    var ref: FIRDatabaseReference!
    var storage: FIRStorage?
    var storageRef: FIRStorageReference?
    var user: FIRUser?
    
    /* Feed View Initialization */

    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        feedStream = [Item]()
        ref = FIRDatabase.database().reference()
        storage = FIRStorage.storage()
        storageRef = storage?.reference()
        let mainRef = ref.child("mainFeed")
        let itemsRef = ref.child("items")
        self.user = (FIRAuth.auth()?.currentUser)
        mainRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //no items exist, stop loading animation
            if !(snapshot.value is NSDictionary) {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        })
        mainRef.observe(FIRDataEventType.childChanged, with: { (snapshot) in
            let feedItemID:String = snapshot.key
            //let feedItemUserID:String = snapshot.value as! String
            itemsRef.child(feedItemID).observeSingleEvent(of: .value, with: { (snapshot) in
                let feedItem = Item(snapshot: snapshot)
                for i in 0...feedStream.count-1 {
                    if feedStream[i].itemID == feedItemID {
                        feedItem.downloadImage(completionHandler: { (done) in
                            if done {
                                feedStream[i] = feedItem
                                self.feedTableView.reloadData()
                            }
                        })
                        break
                    }
                }
            })
        })
        mainRef.observe(FIRDataEventType.childRemoved, with: { (snapshot) in
            let feedItemID:String = snapshot.key
            //let feedItemUserID:String = snapshot.value as! String
            for i in 0...feedStream.count-1 {
                if feedStream[i].itemID == feedItemID {
                    feedStream.remove(at: i)
                    self.feedTableView.reloadData()
                    break
                }
            }
        })
        mainRef.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let feedItemID:String = snapshot.key
            itemsRef.child(feedItemID).observeSingleEvent(of: .value, with: { (snapshot) in
                let feedItem = Item(snapshot: snapshot)
                feedItem.downloadImage(completionHandler: { (done) in
                    if done {
                        feedStream.insert(feedItem, at: 0)
                        activityIndicator.stopAnimating()
                        activityIndicator.isHidden = true
                        self.feedTableView.reloadData()
                    }
                })
            })
        }) 
        //called when item details are changed
        itemsRef.observe(.childChanged, with: { (snapshot) in
            let itemID:String = snapshot.key
            let itemDictionary = snapshot.value as! [String:AnyObject]
            let itemImagePath = itemDictionary["itemImagePath"] as! String
            let changedItem = Item(snapshot: snapshot)
            for (itemNum, item) in feedStream.enumerated() {
                if item.itemID == itemID {
                    item.itemImagePath = itemImagePath
                    item.downloadImage(completionHandler: { (done) in
                        feedStream[itemNum] = changedItem
                        self.feedTableView.reloadData()
                    })
                    break
                }
            }
        })

        //message indicator for tab bar controller
        let messageSetsRef = ref.child("users").child((user?.uid)!).child("messageSets")
        messageSetsRef.observe(.childAdded, with: { (snapshot) in
            let messageSetDetails = snapshot.value as! [String:AnyObject]
            //snapshot.didChangeValue(forKey: "messageUnread")
            //snapshot.willChangeValue(forKey: "messageUnread")
            messageSetsRef.child(messageSetDetails["messageUnread"] as! String).observe(.value, with: { (snapshot) in
                print("messageUnread changed")
                if messageSetDetails["messageUnread"] as! String == "true" {
                    print("updating message count: \(messageCount)")
                    messageCount += 1
                }else{
                    if messageCount > 0 {
                        messageCount -= 1
                    }
                }
                if messageCount > 0{
                    self.tabBarController?.tabBar.items?[1].badgeValue = "\(messageCount)"
                }else{
                    self.tabBarController?.tabBar.items?[1].badgeValue = nil
                }
            })
        })
        
        globalFeedTableView = feedTableView
        feedSearchBar.delegate = self
        feedSearchBar.enablesReturnKeyAutomatically = true
        feedSearchBar.searchBarStyle = UISearchBarStyle.minimal
        feedSearchBar.returnKeyType = UIReturnKeyType.search
        clearFilterButton.isHidden = true
        clearFilterButton.layer.cornerRadius = 5
        clearFilterButton.clipsToBounds = true
        clearFilterButton.layer.borderColor = UIColor.black.cgColor
        self.feedTableView.reloadData()
    }
    
    /* Feed View Transition Management */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let destination = segue.destination as? ItemViewController {
                destination.item = feedStream[selectedRow]
                destination.feedSegue = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        feedSearchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        feedTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*Segues*/
    @IBAction func unwindFilter(segue: UIStoryboardSegue){
        if let source = segue.source as? FilterViewController {
            if source.selectedCategories.count == 0 && source.priceRange == [] {
                return
            }
            print("\(source.selectedCategories)")
            print("\(source.priceRange)")
            print("\(source.priceRange.count)")
            self.filtered = true
            self.filterCategories = source.selectedCategories
            clearFilterButton.isHidden = false
            self.filterStream = []
            for item in feedStream {
                let tagBools = item.itemCategories.map{ self.filterCategories.contains($0) }
                if (tagBools.contains(true) || self.filterCategories.count == 0) && ((source.priceRange == [])||(source.priceRange.count == 2 && item.itemPrice <= source.priceRange[1] && item.itemPrice >= source.priceRange[0])){
                    print("Item was chosen")
                    self.filterStream.append(item)
                }
            }
            self.feedTableView.reloadData()
        }
    }
    
    @IBAction func unwindToFeed(segue: UIStoryboardSegue){
        self.feedTableView.reloadData()
    }
    
    /* Feed Table View Delegate Methods */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchMode {
            return searchStream.count
        }
        else if filtered {
            return filterStream.count
        }
        else{
            return feedStream.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "showItem", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemTableViewCell
        if searchMode {
            cell.itemTitle.text = searchStream[indexPath.row].itemName
            cell.itemPrice.text = "$\(searchStream[indexPath.row].itemCost())"
            cell.itemAuthorWithRating.text = "\(searchStream[indexPath.row].itemUserName)"
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
        }
        else if filtered {
            cell.itemTitle.text = filterStream[indexPath.row].itemName
            cell.itemPrice.text = "$\(filterStream[indexPath.row].itemCost())"
            cell.itemAuthorWithRating.text = "\(filterStream[indexPath.row].itemUserName)"
            let cellLayer : CALayer? = cell.itemImage.layer
            cellLayer!.cornerRadius = 4
            cellLayer!.masksToBounds = true
            cell.itemImage.image = filterStream[indexPath.row].itemImage
            if filterStream[indexPath.row].itemCategories.count > 0 {
                cell.category.text = filterStream[indexPath.row].itemCategories.flatMap({$0.rawValue}).joined(separator: ", ")
            }
            else{
                cell.category.text = "None"
            }
        }
        else {
            cell.itemTitle.text = feedStream[indexPath.row].itemName
            cell.itemPrice.text = "$\(feedStream[indexPath.row].itemCost())"
            cell.itemAuthorWithRating.text = "\(feedStream[indexPath.row].itemUserName)"
            let cellLayer : CALayer? = cell.itemImage.layer
            cellLayer!.cornerRadius = 4
            cellLayer!.masksToBounds = true
            cell.itemImage.image = feedStream[indexPath.row].itemImage
            if feedStream[indexPath.row].itemCategories.count > 0 {
                cell.category.text = feedStream[indexPath.row].itemCategories.flatMap({$0.rawValue}).joined(separator: ", ")
            }
            else{
                cell.category.text = "None"
            }
        }
        return cell
    }
    
    /* Feed Search Bar Delegate Methods */
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchMode = true
        feedSearchBar.endEditing(true)
        feedTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchMode = false
        searchStream = []
        feedSearchBar.text = ""
        feedSearchBar.endEditing(true)
        feedTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        feedSearchBar.showsCancelButton = true
        searchMode = true
        searchStream = []
        feedTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTerm = searchText
        self.searchStream = []
        for item in feedStream {
            // Change/add anything to search?
            if item.itemName.contains(searchText) || item.itemDescription.contains(searchText) {
                searchStream.append(item)
            }
        }
        feedTableView.reloadData()
    }
    
    /* Feed View Utilities */
    
    enum FeedErrors: Error {
        case FailedToLoadFeed
    }
}
