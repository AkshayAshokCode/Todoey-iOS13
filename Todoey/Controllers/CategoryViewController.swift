//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Akshay Ashok on 16/02/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
    
        saveCategories()
      
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - TableView Manipulation Methods
    func saveCategories(){
        do{
            try context.save()
        }catch{
           print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }

    func loadCategories(with request : NSFetchRequest<Category> = Category.fetchRequest()){
       
        do{
            categories = try context.fetch(request)
        }catch{
           print("Error fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default){ (action) in
           
            let newItem = Category(context: self.context)
            newItem.name = textField.text!
            self.categories.append(newItem)
            
            self.saveCategories()
        }
        alert.addAction(action)
        
        alert.addTextField{ (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
            
        }
        
        present(alert, animated: true, completion: nil)
    }
  
}
