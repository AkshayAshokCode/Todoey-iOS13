//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Akshay Ashok on 16/02/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        loadCategories()
    }

   
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numCat = categories?.count
        if numCat == 0 {
            return 1
        }
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if categories?.count == 0{
            cell.textLabel?.text = "No Categories added yet"
        }else{
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories added yet"
        }
       
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        if categories?.count != 0 {
            performSegue(withIdentifier: "goToItems", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if categories?.count != 0 {
            let destinationVC = segue.destination as! TodoListViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
       
    }
    
    //MARK: - TableView Manipulation Methods
    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }

    func loadCategories(){
       
        categories = realm.objects(Category.self)
        
        tableView.reloadData()

    }
    
    //MARK: Delete Data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do{
                try self.realm.write{
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
               print("Error saving context \(error)")
            }
            
        }
     
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default){ (action) in
           
            let newItem = Category()
            newItem.name = textField.text!
            if !textField.text!.isEmpty {
                self.save(category: newItem)
            }
           
        }
        alert.addAction(action)
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
            
        }
        
        present(alert, animated: true, completion: nil)
    }
  
}


