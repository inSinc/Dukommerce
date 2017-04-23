//
//  HistoryViewController.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/8/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase

class HistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /* History View Storyboard Outlets */
    
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBOutlet weak var historyCollectionView: UICollectionView!

    
    /* History View Properties */
    
    var selectedRow = 0
    var activeCollectionStream: [Item] = []
    var soldStream: [Item] = []
    var purchasedStream: [Item] = []
    var usersRef: FIRDatabaseReference?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var user: FIRUser?
    var itemsRef: FIRDatabaseReference?
    
    /* History View Initialization */
    
    @IBAction func changeSegmentedControl(_ sender: Any) {
        historyCollectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        collectionLayout.itemSize = CGSize(width: 120, height: 140)
        historyCollectionView!.dataSource = self
        historyCollectionView!.delegate = self
        historyCollectionView!.collectionViewLayout = collectionLayout
        usersRef = ref.child("users")
        user = FIRAuth.auth()?.currentUser
        itemsRef = ref.child("items")
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        let soldRef = usersRef?.child(user!.uid).child("sold")
        soldRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            //no items exist, stop loading animation
            if !(snapshot.value is NSDictionary) && self.segmentedControl.selectedSegmentIndex == 0 {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        })
        soldRef?.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let itemID:String = snapshot.key
            self.itemsRef?.child(itemID).observeSingleEvent(of: .value, with: { (snapshot) in
                let soldItem = Item(snapshot: snapshot)
                soldItem.itemImagePath = "itemImages/\(soldItem.itemID)"
                soldItem.downloadImage(completionHandler: { (done) in
                    if done {
                        soldItem.downloadImage(completionHandler: { (done) in
                            self.soldStream.insert(soldItem, at: 0)
                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                activityIndicator.stopAnimating()
                                activityIndicator.isHidden = true
                            }
                            self.historyCollectionView.reloadData()
                        })

                    }
                })
            })
        })
        let purchasedRef = usersRef?.child(user!.uid).child("bought")
        purchasedRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            //no items exist, stop loading animation
            if !(snapshot.value is NSDictionary) && self.segmentedControl.selectedSegmentIndex == 1 {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        })
        purchasedRef?.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            let itemID:String = snapshot.key
            self.itemsRef?.child(itemID).observeSingleEvent(of: .value, with: { (snapshot) in
                let purchasedItem = Item(snapshot: snapshot)
                purchasedItem.itemImagePath = "itemImages/\(purchasedItem.itemID)"
                purchasedItem.downloadImage(completionHandler: { (done) in
                    if done {
                        purchasedItem.downloadImage(completionHandler: {(done) in
                            if done {
                                self.purchasedStream.insert(purchasedItem, at: 0)
                                if self.segmentedControl.selectedSegmentIndex == 0 {
                                    activityIndicator.stopAnimating()
                                    activityIndicator.isHidden = true
                                }
                                self.historyCollectionView.reloadData()
                            }
                        })

                    }
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* History View Collection Methods */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (segmentedControl.selectedSegmentIndex == 0) ? soldStream.count : purchasedStream.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = historyCollectionView!.dequeueReusableCell(withReuseIdentifier: "itemCollectionCell", for: indexPath) as! ItemCollectionViewCell
        let cellLayer : CALayer? = cell.itemImage.layer
        cellLayer!.cornerRadius = 20
        cellLayer!.masksToBounds = true
        cell.itemImage.image = (segmentedControl.selectedSegmentIndex == 0) ? soldStream[indexPath.row].itemImage : purchasedStream[indexPath.row].itemImage
        cell.itemName.text = (segmentedControl.selectedSegmentIndex == 0) ? soldStream[indexPath.row].itemName : purchasedStream[indexPath.row].itemName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "showItem", sender: self)
    }
    
    /* History View Controller Segue Management */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem" {
            if let destination = segue.destination as? ItemViewController {
                destination.item = (segmentedControl.selectedSegmentIndex == 0) ? soldStream[selectedRow] : purchasedStream[selectedRow]
            }
        }
    }
    
}
