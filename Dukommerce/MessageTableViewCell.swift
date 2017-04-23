//
//  MessageTableViewCell.swift
//  Dukommerce
//
//  Created by Sinclair on 4/9/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var unreadImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
