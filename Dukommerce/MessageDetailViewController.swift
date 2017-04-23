//
//  MessageDetailViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase

class MessageDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    /* Message Detail View Storyboard Outlets */
    
    @IBOutlet weak var itemButton: UIButton!
    @IBAction func itemButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "showItem", sender: nil)
    }
    @IBOutlet var messageComposeView: UIView!
    @IBOutlet weak var messageConversationTableView: UITableView!
    @IBOutlet weak var messageComposeTextField: UITextField!
    @IBAction func sendAction(_ sender: Any) {
        view.endEditing(true)
        let messageUserName = user!.displayName!
        let messageUserID = user!.uid
        let messageString = messageComposeTextField.text
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, hh:mm"
        let messageTime = dateFormatter.string(from: Date())
        let newMessageRef = messagesRef?.childByAutoId()
        let messageID = newMessageRef?.key
        let newMessage = Message(messageUserName: messageUserName, messageUserID: messageUserID, messageString: messageString!, messageTime: messageTime, messageID: messageID!)
        let messageDict = newMessage.messageToDict()
        newMessageRef?.setValue(messageDict)
        self.messageSetRef?.child("lastTimeStamp").setValue(messageTime)
        self.messageSetRef?.child("lastMessage").setValue(messageString)
        self.otherUserMessageSetRef?.child("lastTimeStamp").setValue(messageTime)
        self.otherUserMessageSetRef?.child("lastMessage").setValue(messageString)
        self.otherUserMessageSetRef?.child("messageUnread").setValue("true")
        self.otherUserMessagesRef?.child(messageID!).setValue(messageDict)
        messageComposeTextField.text = ""
        messageConversationTableView.reloadData()
        messageConversationTableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.bottom, animated: false)
    }
    
    /* Message Detail View Properties */
    var activeTextField: UITextField?
    var messageIndex: Int?
    var messageSet: MessageSet?
    var dateFormatter : DateFormatter = DateFormatter()
    var messages: [Message] = []
    
    var initialBuy: Bool? //indicates if coming from Item View Controller...initial buy
    var messageSetItemID: String?
    var messageSetItemName: String?
    var otherUserName: String?
    var otherUserID: String?
    var user: FIRUser?
    var userRef: FIRDatabaseReference?
    var otherUserRef: FIRDatabaseReference?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var messageSetRef: FIRDatabaseReference?
    var messagesRef: FIRDatabaseReference?
    var otherUserMessageSetRef: FIRDatabaseReference?
    var otherUserMessagesRef: FIRDatabaseReference?
    
    /* Message Detail View Initialization */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        messageConversationTableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.bottom, animated: false)
        self.messageComposeTextField.delegate = self
        self.user = (FIRAuth.auth()?.currentUser)
        self.otherUserRef = ref.child("users").child(otherUserID!)
        //messageSet?.printMessageSet()
        userRef = ref.child("users").child((user?.uid)!)
        //coming from item detail view, initial buy
        if initialBuy == true{
            dateFormatter.dateFormat = "dd MMM, hh:mm"
            let messageTime = dateFormatter.string(from: Date())
            self.messageSetRef = userRef?.child("messageSets").childByAutoId()
            let messageSetID = messageSetRef?.key
            //initializing message set for current user
            messageSet = MessageSet(otherUserName: otherUserName!, otherUserID: otherUserID!, messageSetID: messageSetID!, messageSetItemName: messageSetItemName!, messageSetItemID: messageSetItemID!, lastTimeStamp: messageTime, lastMessage: "", messageUnread: "false")
            messageSetRef?.setValue(messageSet?.messageSetToDict())
            //establishing message set for receiver (other user)
            let otherUserMessageSet = MessageSet(otherUserName: (user?.displayName)!, otherUserID: (user?.uid)!, messageSetID: messageSetID!, messageSetItemName: messageSetItemName!, messageSetItemID: messageSetItemID!, lastTimeStamp: messageTime, lastMessage: "", messageUnread: "true")
            otherUserRef?.child("messageSets").child(messageSetID!).setValue(otherUserMessageSet.messageSetToDict())
            self.otherUserMessageSetRef = otherUserRef?.child("messageSets").child(messageSetID!)
        }else{
            //loading from messages view controller
            self.otherUserID = messageSet?.otherUserID
            self.otherUserRef = ref.child("users").child(otherUserID!)
            messages = (messageSet?.messages)!
            self.messageSetRef = userRef?.child("messageSets").child((messageSet?.messageSetID)!)
            self.otherUserMessageSetRef = otherUserRef?.child("messageSets").child((messageSet?.messageSetID)!)
        }
        userRef?.child("posted").observeSingleEvent(of: .value, with: { (snapshot) in
            let search = snapshot.childSnapshot(forPath: self.messageSetItemID!)
            //print(search.value!)
            if search.value! is NSString {
                let finalizeSell = UIBarButtonItem(title: "Sell", style: .plain, target: self, action:#selector(MessageDetailViewController.finalizeSell))
                self.navigationItem.rightBarButtonItem  = finalizeSell
                //self.navigationController?
            }
        })
        self.messagesRef = messageSetRef?.child("messages")
        self.otherUserMessagesRef = otherUserMessageSetRef!.child("messages")
        itemButton.setTitle(messageSet?.messageSetItemName, for: UIControlState.normal)
        //set message observer here...
        messagesRef?.observe(.childAdded, with: { (snapshot) in
            let messageItem = Message(snapshot: snapshot)
            self.messages.append(messageItem)
            self.messageConversationTableView.reloadData()
            let point = CGPoint(x: 0, y: self.messageConversationTableView.contentSize.height - self.messageConversationTableView.frame.size.height)
            self.messageConversationTableView.setContentOffset(point, animated: true)
        })
        messageSet?.messageUnread = "false"
        self.messageSetRef?.child("messageUnread").setValue("false")
        self.dateFormatter.dateFormat = "dd MMM, hh:mm"
        messageConversationTableView.delegate = self
        messageConversationTableView.dataSource = self
        messageConversationTableView.allowsSelection = false
    }
    
    func finalizeSell(){
        let alert = UIAlertController(title: "Confirming sell?", message: "You are confirming buyer has received product. This item will be moved to your history and this chat will be deleted as well.", preferredStyle: UIAlertControllerStyle.alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (alertAction) in
            self.sell()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func sell(){
        userRef?.child("sold").child((messageSet?.messageSetItemID)!).setValue(messageSet?.messageSetItemName)
        otherUserRef?.child("bought").child((messageSet?.messageSetItemID)!).setValue(messageSet?.messageSetItemName)
        userRef?.child("messageSets").child((messageSet?.messageSetID)!).removeValue()
        userRef?.child("posted").child((messageSet?.messageSetItemID)!).removeValue()
        otherUserRef?.child("messageSets").child((messageSet?.messageSetID)!).removeValue()
        ref.child("mainFeed").child(messageSetItemID!).removeValue()
        performSegue(withIdentifier: "unwindToMessages", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* Message Detail View Table View Management */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageConversationTableView.dequeueReusableCell(withIdentifier: "messageDetailCell") as! MessageConversationTableViewCell
        let message = messages[indexPath.row]
        cell.messageAuthor.text = message.messageUserName
        cell.messageBody.text = message.messageString
        cell.timeStamp.text = message.messageTime
        return cell
    }
    
    /* Message Detail View Keyboard Management */
    
    var labelCovered: Bool = false
    var viewY: CGFloat = 0
    
    func keyboardWillShow(notification:NSNotification){
        if self.activeTextField != nil {
            labelCovered = true
            viewY = self.view.frame.origin.y
            self.view.frame.origin.y -= 160
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
        if touches.first?.view != messageConversationTableView || activeTextField == nil {
            view.endEditing(true)
        }
        else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItem"{
            let destination = segue.destination as! ItemViewController
            var itemToPass: Item?
            //print("messageSetItemID: ",messageSetItemID)
            for item in feedStream {
                print(item.itemID)
                if item.itemID == messageSetItemID{
                    itemToPass = item
                    break
                }
            }
            destination.item = itemToPass
            destination.comingFromBuyThread = true
        }
        else if segue.identifier == "unwindToMessages" {
            let destination = segue.destination as! MessagesViewController
            for i in 0...destination.messageSets.count-1 {
                if destination.messageSets[i].messageSetItemID == messageSetItemID{
                    destination.deletedMessageSetID = messageSet?.messageSetID
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeTextField = nil
        view.endEditing(true)
        return false
    }

}
