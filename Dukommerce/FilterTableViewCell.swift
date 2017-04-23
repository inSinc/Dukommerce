//
//  FilterTableViewCell.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/4/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit

class FilterTableViewCell: UITableViewCell {
    @IBOutlet var filterCategory: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
