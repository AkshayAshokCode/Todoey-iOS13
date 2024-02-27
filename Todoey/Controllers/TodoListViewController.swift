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
    
    var todoItems :Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet{
              loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
       
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour{
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller not set")}
            let backgroundColor = UIColor(hexString: colourHex)
            navBar.backgroundColor = backgroundColor
            searchBar.barTintColor = backgroundColor
            searchBar.searchTextField.backgroundColor = FlatWhite()
            title = selectedCategory!.name
            navBar.barTintColor = backgroundColor
            
            let contrastOfBackgroundColor = ContrastColorOf(backgroundColor!, returnFlat: true)
            
            
            navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastOfBackgroundColor]
            navBar.backgroundColor = backgroundColor
            
            navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastOfBackgroundColor]
                    
            // Color the back button and icons: (both small and large title)
            navBar.tintColor = contrastOfBackgroundColor
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = backgroundColor
            navigationItem.scrollEdgeAppearance = appearance
        }
    }
    
    //MARK: Tableview Datasoruce Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numItem = todoItems?.count
        if numItem == 0 {
            return 1
        }
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if todoItems?.count == 0{
            cell.textLabel?.text = "No Items Added"
        }else{
            if let item = todoItems?[indexPath.row] {
                cell.textLabel?.text = item.title
                
                cell.accessoryType = item.done ? .checkmark : .none
                
            }
            let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count))
            if colour != nil {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour!, returnFlat: true)
            }
           
        }
        
//        if let item = todoItems?[indexPath.row] {
//            cell.textLabel?.text = item.title
//            
//            cell.accessoryType = item.done ? .checkmark : .none
//            
//        }else{
//            cell.textLabel?.text = "No Items Added"
//        }
//        
       
        return cell
    }
    
    //MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if todoItems?.count != 0 {
            if let item = todoItems?[indexPath.row]{
                do{
                    try realm.write{
                        item.done = !item.done
                    }
                } catch{
                    print("Error saving done status, \(error)")
                }
            }
            
        }
       
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(itemForDeletion)
                }
            }catch{
               print("Error saving context \(error)")
            }
            
        }
     
    }
    
    //MARK: Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Items", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default){ (action) in
            
            if !textField.text!.isEmpty {
                if let currentCategory = self.selectedCategory {
                    do{
                        try self.realm.write{
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    }catch{
                       print("Error saving context \(error)")
                    }
                }
            }
            
            
            self.tableView.reloadData()
        }
        alert.addTextField{ (alertTextField) in
                    alertTextField.placeholder = "Create new item"
                    textField = alertTextField
        
                }
        
                alert.addAction(action)
        
                present(alert, animated: true, completion: nil)
    }
        
       
        
    func loadItems(){
                todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
                
        }
    }
    
    //MARK: - Search bar methods
    
    extension TodoListViewController: UISearchBarDelegate{
    
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
              
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if(searchBar.text?.count == 0){
                loadItems()
    
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    
    }

