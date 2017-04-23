//
//  SelectCategoryViewController.swift
//  Dukommerce
//
//  Created by Sinclair on 4/6/17.
//  Copyright © 2017 Sinclair Toffa & Alden Harwood. All rights reserved.
//

import UIKit

class SelectCategoryViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var categories: [Item.ItemCategories] = []
    var selectedCategories: [Item.ItemCategories] = []
    
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBAction func saveAction(_ sender: Any) {
        for i in 0...categoryTableView.numberOfRows(inSection: 0) {
            if categoryTableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType == UITableViewCellAccessoryType.checkmark {
                selectedCategories.append(categories[i])
            }
        }
        
        if selectedCategories.count < 1{
            alertLabel.isHidden = false
        }else{
            performSegue(withIdentifier: "unwindToAdd", sender: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alertLabel.isHidden = true
        categories = Item.ItemCategories.allCategories
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        categoryTableView.allowsMultipleSelection = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Filter View Category Table Methods */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "filterCell") as! FilterTableViewCell
        cell.filterCategory.text = categories[indexPath.row].rawValue
        //cell.filterCategory.textColor = categories[indexPath.row].color()
        cell.accessoryType = .none
        return cell
    }
    
    /* Category View Transition Management */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
