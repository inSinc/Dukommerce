//
//  MessagesViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 3/29/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /* Message View Storyboard Outlets */
    
    @IBOutlet weak var messagesTableView: UITableView!
    var messageSets: [MessageSet]!
    
    var user: FIRUser?
    var ref: FIRDatabaseReference = FIRDatabase.database().reference()
    var messageSetsRef: FIRDatabaseReference! //thread for all messages
    
    /* Message View Properties */
    
    var messageSetIndex: Int = 0
    var dateFormatter : DateFormatter = DateFormatter()
    var deletedMessageSetID:String?

    /* Message View Initialization */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        messageSets = []
        self.user = (FIRAuth.auth()?.currentUser)
        let userRef = ref.child("users").child((user?.uid)!)
        self.messageSetsRef = userRef.child("messageSets")
        messageSetsRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSDictionary) {
                activityIndicator.stopAnimating()
                activityIndicator.isHidden = true
            }
        })
        messageSetsRef.observe(.childRemoved, with: { (snapshot) in
            print("entering delete")
            print(snapshot.key)
            for i in 0...self.messageSets.count-1{
                if self.messageSets[i].messageSetID == snapshot.key{
                    print("deleting item")
                    self.messageSets.remove(at: i)
                    break
                }
            }
            self.messagesTableView.reloadData()
        })
        messageSetsRef.observe(.childAdded, with: { (snapshot) in
            let newMessageSet = MessageSet(snapshot: snapshot)
            self.messageSets.insert(newMessageSet, at: 0)
            self.messagesTableView.reloadData()
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        })
        messageSetsRef.observe(.childChanged, with: { (snapshot) in
            let item = snapshot.value as! [String:AnyObject]
            print(item["messageSetItemID"] as! String)
            for messageSet in self.messageSets{
                if messageSet.messageSetItemID == item["messageSetItemID"] as! String {
                    messageSet.lastMessage = item["lastMessage"] as! String
                    messageSet.lastTimeStamp = item["lastTimeStamp"] as! String
                    messageSet.messageUnread = item["messageUnread"] as! String
                    break
                }
            }
            self.messagesTableView.reloadData()
        })
        self.dateFormatter.dateFormat = "dd MMM, hh:mm"
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.tabBarController?.tabBar.items?[1].badgeValue = nil
        messageCount = 0
    }
    
    /* Message View Table View Methods */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageSets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageSetIndex = indexPath.row
        performSegue(withIdentifier: "showMessage", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messagesTableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
        let messageSet = messageSets[indexPath.row]
        if messageSet.messageUnread == "true"{
            cell.unreadImageView.isHidden = false
        }else{
            cell.unreadImageView.isHidden = true
        }
        cell.senderLabel.text = messageSet.otherUserName
        cell.messageLabel.text = messageSet.lastMessage
        cell.timeLabel.text = messageSet.lastTimeStamp
        cell.itemLabel.text = messageSet.messageSetItemName
        return cell
    }
    
    /* Message View Transition Management */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessage" {
            if let destination = segue.destination as? MessageDetailViewController {
                let messageSet = messageSets[messageSetIndex]
                destination.messageIndex = self.messageSetIndex
                destination.messageSet = messageSet
                destination.otherUserID = messageSet.otherUserID
                destination.messageSetItemID = messageSet.messageSetItemID
            }
        }
    }
    
    @IBAction func unwindToMessages(segue: UIStoryboardSegue){
        
    }
}
