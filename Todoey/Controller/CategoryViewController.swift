//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Khue on 20/10/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    // MARK: - Variable
    let realm = try! Realm()
    var categories: Results<Category>?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
    }
    
    // MARK: - IBAction
    @IBAction func addButtonDidTap(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.color = UIColor.randomFlat().hexValue()
                
                self.save(category: newCategory)
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new category..."
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories!.isEmpty ? 1 : categories!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if categories!.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Categories Added"
            return cell
        } else {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            let currentCategory =  categories![indexPath.row]
            
            cell.textLabel?.text = currentCategory.name
            cell.backgroundColor = UIColor(hexString: currentCategory.color)
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return categories!.isEmpty ? nil : indexPath
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Data Manipulations
    func save(category: Category){
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error saving data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - SwipeTableViewController
    override func updateModel(at indexPath: IndexPath) {
        if !categories!.isEmpty {
            do {
                try self.realm.write({
                    self.realm.delete(self.categories![indexPath.row])
                })
            } catch {
                print("Error deleting data: \(error)")
            }
        }
    }
}
