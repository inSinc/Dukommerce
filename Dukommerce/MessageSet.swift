//
//  MessageSet.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import Firebase

class MessageSet {
    
    /* Message Set Properties */
    
    var otherUserName: String
    var otherUserID: String
    var messageSetID: String
    var messageSetItemName: String
    var messageSetItemID: String
    var messages: [Message]
    var lastTimeStamp: String
    var lastMessage: String
    var messageUnread: String
    
    /* Message Set Initialization */
    
    init(otherUserName: String, otherUserID: String, messageSetID: String, messageSetItemName: String, messageSetItemID: String, lastTimeStamp: String, lastMessage: String, messageUnread: String){
        self.otherUserID = otherUserID
        self.otherUserName = otherUserName
        self.messageSetID = messageSetID
        self.messageSetItemName = messageSetItemName
        self.messageSetItemID = messageSetItemID
        self.messages = []
        self.lastTimeStamp = lastTimeStamp
        self.lastMessage = lastMessage
        self.messageUnread = messageUnread
    }
    
    init(snapshot: FIRDataSnapshot){
        let item = snapshot.value as! [String:AnyObject]
        //print("\(item)")
        self.otherUserID = item["otherUserID"] as! String
        self.otherUserName = item["otherUserName"] as! String
        self.messageSetID = item["messageSetID"] as! String
        self.messageSetItemName = item["messageSetItemName"] as! String
        self.messageSetItemID = item["messageSetItemID"] as! String
        self.messages = []
        self.lastTimeStamp = item["lastTimeStamp"] as! String
        self.lastMessage = item["lastMessage"] as! String
        if item["messages"] is NSDictionary {
            let messagesToProcess = item["messages"] as! [String:AnyObject]
            print(messagesToProcess)
            for message in messagesToProcess {
                let messageDetails = message.value as! [String:AnyObject]
                let newMessage = Message(messageUserName: messageDetails["messageUserName"] as! String, messageUserID: messageDetails["messageUserID"] as! String, messageString: messageDetails["messageString"] as! String, messageTime: messageDetails["messageTime"] as! String, messageID: messageDetails["messageID"] as! String)
                messages.append(newMessage)
            }
        }
        self.messageUnread = item["messageUnread"] as! String
    }
    
    func messageSetToDict() -> [String: String]{
        return ["otherUserName":otherUserName,"otherUserID":otherUserID,"messageSetID":messageSetID,"messageSetItemName":messageSetItemName,"messageSetItemID":messageSetItemID,"messages":"","lastTimeStamp":lastTimeStamp,"lastMessage":lastMessage,"messageUnread":messageUnread]
    }
    
    func printMessageSet(){
        print("Other user name: \(otherUserName)")
        print("Other user id: \(otherUserID)")
        print("Message set id: \(messageSetID)")
        print("Message set item name: \(messageSetItemName)")
        print("Message set item id: \(messageSetItemID)")
        print("Last time stamp: \(lastTimeStamp)")
        print("Last message: \(lastMessage)")
        print("Messages: \(messages)")
        print("Message unread: \(messageUnread)")
    }
}
