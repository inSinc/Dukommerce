//
//  MessageConversationTableViewCell.swift
//  Dukommerce
//
//  Created by Sinclair on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit

class MessageConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var messageAuthor: UILabel!
    @IBOutlet weak var messageBody: UITextView!
    @IBOutlet weak var timeStamp: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
