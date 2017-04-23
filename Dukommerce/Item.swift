//
//  PostedItem.swift
//  Dukommerce
//
//  Created by Alden Harwood on 3/30/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

class Item {
    
    /* Item Properties */
    
    var itemUserName: String
    var itemUserID: String
    var itemName: String
    var itemPrice: Double
    var itemCondition: String // Make an enum or leave ambiguous?
    var itemStatus: ItemStatus
    var itemDescription: String
    var itemImage: UIImage
    var itemImagePath: String
    var itemID: String
    var itemCategories: [ItemCategories]
    var itemPostedDate: String
    
    var storageRef: FIRStorageReference = FIRStorage.storage().reference()
    
    /* Firebase Storing Methods */
    
    func itemToDict() -> [String:String] {
        let categories = self.itemCategories.flatMap({$0.rawValue}).joined(separator: ", ")
        return ["itemUserName": self.itemUserName, "itemUserID": self.itemUserID, "itemName":self.itemName, "itemPrice":String(self.itemPrice), "itemCondition":self.itemCondition, "itemStatus":self.itemStatus.rawValue, "itemDescription": itemDescription, "itemCategories": categories, "itemPostedDate": self.itemPostedDate, "itemID":itemID, "itemImagePath":self.itemImagePath]
    }
    
    /* Item Initializers */
    
    init(snapshot: FIRDataSnapshot){
        let item = snapshot.value as! [String:AnyObject]
        //print("\(item)")
        let categoryStrings: [String] = (item["itemCategories"] as! String).components(separatedBy: ", ")
        var categories : [ItemCategories] = []
        for category in categoryStrings {
            categories.append(ItemCategories.init(rawValue: category)!)
        }
        self.itemCategories = categories
        self.itemUserID = item["itemUserID"] as! String
        self.itemName = item["itemName"] as! String
        self.itemPrice = Double(item["itemPrice"] as! String)!
        self.itemCondition = item["itemCondition"] as! String
        self.itemStatus = ItemStatus.init(rawValue: item["itemStatus"] as! String)!
        self.itemDescription = item["itemDescription"] as! String
        self.itemPostedDate = item["itemPostedDate"] as! String
        self.itemID = item["itemID"] as! String
        self.itemUserName = item["itemUserName"] as! String
        self.itemImage = UIImage(named: "defaultItem")!
        self.itemImagePath = item["itemImagePath"] as! String
        downloadImage(completionHandler: {_ in })
    }
    
    init(itemUserName: String, itemUserID: String, itemName: String, itemPrice: Double, itemCondition: String, itemStatus: ItemStatus, itemDescription: String, itemCategories: [ItemCategories], itemDate: String, itemID: String, itemImagePath: String){
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.itemCondition = itemCondition
        self.itemStatus = itemStatus
        self.itemDescription = itemDescription
        self.itemCategories = itemCategories
        self.itemPostedDate = itemDate
        self.itemID = itemID
        self.itemUserID = itemUserID
        self.itemUserName = itemUserName
        self.itemImage = UIImage(named: "defaultItem")!
        self.itemImagePath = itemImagePath
    }
    
    func downloadImage(completionHandler: @escaping (_ isDone: Bool) -> Void){
        //storageRef
        let imageDownloadPath = storageRef.child(itemImagePath)
        imageDownloadPath.data(withMaxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                //Error dang:/
                print("Error downloading image: \(error.debugDescription)")
                completionHandler(false)
            } else {
                print("image successfully downloaded")
                self.itemImage = UIImage(data: data!)!
                globalFeedTableView.reloadData()
                completionHandler(true)
            }
        }
    }
    
    /* Item Enums */
    
    enum ItemStatus: String {
        case NewItem = "new"
        case ActiveItem = "active"
        case SoldItem = "sold"
    }
    
    enum ItemCategories: String {
        case Appliances = "Appliances"
        case Entertainment = "Entertainment"
        case Furniture = "Furniture"
        case Outdoors = "Outdoors"
        case School = "School"
        case Other = "Other"
        
        func color() -> UIColor {
            switch self {
            case .Appliances:
                return UIColor.red
            case .Entertainment:
                return UIColor.orange
            case .Furniture:
                return UIColor.yellow
            case .Outdoors:
                return UIColor.green
            case .School:
                return UIColor.blue
            case .Other:
                return UIColor.purple
            }
        }
        
        static let allCategories = [Appliances, Entertainment, Furniture, Outdoors, School, Other]
    }
    
    /* Item Random */
    
    func itemCost() -> String {
        return String(format: "%.2f", self.itemPrice)
    }
}
