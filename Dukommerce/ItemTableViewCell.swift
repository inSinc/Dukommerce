//
//  ItemTableViewCell.swift
//  Dukommerce
//
//  Created by Sinclair on 3/30/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemAuthorWithRating: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
