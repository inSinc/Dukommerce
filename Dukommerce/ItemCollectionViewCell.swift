//
//  ItemCollectionViewCell.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/2/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet var itemImage: UIImageView!
    @IBOutlet var itemName: UILabel!
    override var reuseIdentifier: String?{
        return "itemCollectionCell"
    }
}
