//
//  UserProfile.swift
//  Dukommerce
//
//  Created by Alden Harwood on 3/30/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit

class User {
    
    /* User Properties */
    
    var userName: String
    var userImage: UIImage?
    var userPostedItems: [Item]
    var userSavedItems: [Item]
    var userSoldItems: [Item]
    var userBoughtItems: [Item]
    var userRatings: [Int]
    var userAverageRating: Int?
    var userSettings: UserSettings
    var userMessageSets: [MessageSet]
    var userID: String
    
    /* User Initializers */
    
    init(userName: String, userImage: UIImage){
        self.userName = userName
        self.userImage = userImage
        self.userPostedItems = [Item]()
        self.userSavedItems = [Item]()
        self.userRatings = [Int]()
        self.userSoldItems = [Item]()
        self.userBoughtItems = [Item]()
        self.userSettings = UserSettings()
        self.userID = userName
        self.userMessageSets = []
    }
    
    /* User Posted Item Management */
    
    func removePostedItemWithID(itemID: String) throws {
        if let itemIndex = self.userPostedItems.index(where: {$0.itemID == itemID}){
            self.userPostedItems.remove(at: itemIndex)
        }
        else {
            throw UserProfileErrors.InvalidPostedItemID
        }
    }
    
    func setPostedItemWithIDAsActive(itemID: String) throws {
        if let itemIndex = self.userPostedItems.index(where: {$0.itemID == itemID}){
            self.userPostedItems[itemIndex].itemStatus = Item.ItemStatus.ActiveItem
        }
        else {
            throw UserProfileErrors.InvalidPostedItemID
        }
    }
    
    func setPostedItemWithIDAsSold(itemID: String) throws {
        if let itemIndex = self.userPostedItems.index(where: {$0.itemID == itemID}){
            self.userPostedItems[itemIndex].itemStatus = Item.ItemStatus.SoldItem
        }
        else {
            throw UserProfileErrors.InvalidPostedItemID
        }
    }
    
    /* User Saved Item Management */
    
    func removeSavedItemWithID(itemID: String) throws {
        if let itemIndex = self.userSavedItems.index(where: {$0.itemID == itemID}){
            self.userSavedItems.remove(at: itemIndex)
        }
        else {
            throw UserProfileErrors.InvalidSavedItemID
        }
    }
    
    /* User Profile Other */
    
    enum UserProfileErrors: Error {
        case InvalidSavedItemID
        case InvalidPostedItemID
    }
}
