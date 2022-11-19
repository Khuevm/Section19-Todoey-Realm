//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    // MARK: - IBOutlet
    @IBOutlet var searchBar: UISearchBar!
    
    // MARK: - Variable
    let realm = try! Realm()
    
    var items: Results<Item>?
    var selectedCategory: Category? {
        // didSet dc gọi ngay khi biến có giá trị
        didSet {
            loadItems()
        }
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let color = selectedCategory?.color else {
            fatalError("Error unwrapping selected category color")
        }
        
        //SearchBar
        searchBar.barTintColor = UIColor(hexString: color)
        searchBar.searchTextField.backgroundColor = .white
        
        //NavigationBar
        title = selectedCategory!.name
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(hexString: color)
        appearance.titleTextAttributes = [.foregroundColor: ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)]
        appearance.largeTitleTextAttributes = [.foregroundColor: ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
        
    }
    
    // MARK: - IBAction
    @IBAction func addButtonDidTap(_ sender: Any) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { [self] action in
            //What will happen if user tap the Add Item Button
            if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
                //Create in CRUD
                if let parentCategory = self.selectedCategory {
                    do {
                        try self.realm.write({
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            parentCategory.items.append(newItem)
                        })
                    } catch {
                        print("Error saving items: \(error)")
                    }
                }
                tableView.reloadData()
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item..."
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.isEmpty ? 1 : items!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if items!.isEmpty {
            //Nếu k có item -> k dc vuốt cell
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Items"
            return cell
        } else {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if let currentItem = items?[indexPath.row] {
                let color = UIColor(hexString: selectedCategory!.color)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count))!
                cell.textLabel?.text = currentItem.title
                cell.accessoryType = currentItem.isDone ? .checkmark : .none
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            return cell
        }
    }
    
    // Non-selectable if don't have items
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return items!.isEmpty ? nil : indexPath
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Update in CRUD
        if !items!.isEmpty {
            let currentItem = items![indexPath.row]
            do {
                try realm.write({
                    currentItem.isDone = !currentItem.isDone
                })
            } catch {
                print("Error updating data: \(error)")
            }
            
            tableView.reloadData()
        }
    }
    
    // MARK: - Data Manipulations
    //Read in CRUD
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated")
        tableView.reloadData()
    }
    
    // MARK: - SwipeTableViewController
    //Delete in CRUD
    override func updateModel(at indexPath: IndexPath) {
        if !items!.isEmpty {
            do {
                try realm.write({
                    realm.delete(items![indexPath.row])
                })
            } catch {
                print("Error deleting data: \(error)")
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadItems()
        if searchBar.text?.count != 0 {
            //filter
            //[cd]: c-ko phân biệt chữ hoa chữ thường, d-ko phân biệt có dấu
            items = items?.filter("title CONTAINS [cd] %@", searchBar.text!).sorted(byKeyPath: "title")
            tableView.reloadData()
        }
    }
}
