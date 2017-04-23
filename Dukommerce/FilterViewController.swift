//
//  FilterViewController.swift
//  Dukommerce
//
//  Created by Alden Harwood on 4/4/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import Foundation
import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    /* Filter View Properties */

    var filterCategories: [Item.ItemCategories] = []
    var selectedCategories: [Item.ItemCategories] = []
    var priceRange : [Double] = []
    var activeTextField: UITextField?
    
    /* Filter View Storyboard Outlets */
    
    @IBOutlet var filterTableView: UITableView!
    @IBOutlet var minPrice: UITextField!
    @IBOutlet var maxPrice: UITextField!
    
    /* Filter View Initialization */
    
    override func viewDidLoad() {
        priceRange = []
        filterCategories = Item.ItemCategories.allCategories
        filterTableView.delegate = self
        minPrice.delegate = self
        maxPrice.delegate = self
        let minPriceBottomLine = CALayer()
        minPriceBottomLine.frame = CGRect(x: 0.0, y: minPrice.frame.height - 1,width: minPrice.frame.width,height: 0.5)
        minPriceBottomLine.backgroundColor = UIColor.white.cgColor
        minPrice.borderStyle = UITextBorderStyle.none
        minPrice.layer.addSublayer(minPriceBottomLine)
        let maxPriceBottomLine = CALayer()
        maxPriceBottomLine.frame = CGRect(x: 0.0, y: maxPrice.frame.height - 1,width: maxPrice.frame.width,height: 0.5)
        maxPriceBottomLine.backgroundColor = UIColor.white.cgColor
        maxPrice.borderStyle = UITextBorderStyle.none
        maxPrice.layer.addSublayer(maxPriceBottomLine)
        filterTableView.dataSource = self
        filterTableView.allowsMultipleSelection = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /* Filter View Category Table Methods */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = filterTableView.dequeueReusableCell(withIdentifier: "filterCell") as! FilterTableViewCell
        cell.filterCategory.text = filterCategories[indexPath.row].rawValue
        cell.accessoryType = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    /* Filter View Transition Management */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        for i in 0...filterTableView.numberOfRows(inSection: 0) {
            if filterTableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType == UITableViewCellAccessoryType.checkmark {
                selectedCategories.append(filterCategories[i])
            }
        }
        
        if let min = Double(minPrice.text!), let max = Double(maxPrice.text!) {
            priceRange = [min, max]
        }
    }
    
    /* Filter View Keyboard Management */
    
    var labelCovered: Bool = false
    var viewY: CGFloat = 0
    
    func keyboardWillShow(notification:NSNotification){
        if self.activeTextField != nil {
            labelCovered = true
            viewY = self.view.frame.origin.y
            self.view.frame.origin.y -= 100
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
        if touches.first?.view != filterTableView || activeTextField == nil {
            view.endEditing(true)
        }
        else {
            super.touchesBegan(touches, with: event)
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
