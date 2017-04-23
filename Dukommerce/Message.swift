//
//  Message.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    /* Message Properties */
    
    var messageUserName: String
    var messageUserID: String
    var messageString: String
    var messageTime: String
    var messageID: String
    
    /* Message Initialization */
    
    init(messageUserName: String, messageUserID: String, messageString: String, messageTime: String, messageID: String){
        self.messageUserName = messageUserName
        self.messageUserID = messageUserID
        self.messageString = messageString
        self.messageTime = messageTime
        self.messageID = messageID
    }
    
    init(snapshot: FIRDataSnapshot){
        let item = snapshot.value as! [String:AnyObject]
        self.messageUserName = item["messageUserName"] as! String
        self.messageUserID = item["messageUserID"] as! String
        self.messageString = item["messageString"] as! String
        self.messageTime = item["messageTime"] as! String
        self.messageID = item["messageID"] as! String
    }
    
    func messageToDict() -> [String:String]{
        return ["messageUserName":messageUserName,"messageUserID":messageUserID,"messageString":messageString,"messageTime":messageTime,"messageID":messageID]
    }
}
