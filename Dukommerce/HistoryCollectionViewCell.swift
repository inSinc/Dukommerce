//
//  HistoryCollectionViewCell.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/8/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit

class HistoryCollectionViewCell: UICollectionViewCell {
    
    /* History Collection View Storyboard Outlets */
    
    @IBOutlet var historyImage: UIImageView!
    @IBOutlet var historyLabel: UILabel!
    override var reuseIdentifier: String?{
        return "historyCell"
    }
    
}
