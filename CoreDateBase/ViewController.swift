//
//  ViewController.swift
//  CoreDateBase
//
//  Created by Ramazan Burak Ekinci on 8.11.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = "";
    var selectedPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create the appbar and add button.
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addNewData))
        
        //tableView initialize
        tableView.delegate      = self
        tableView.dataSource    = self
        
        //call function
        getData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    @objc func getData(){
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        //Access to AppDeledate class
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //fetch to entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        fetchRequest.returnsObjectsAsFaults = false
        
        //get
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let newName = result.value(forKey: "name") as? String{
                        self.nameArray.append(newName)
                    }
                    if let newId = result.value(forKey: "id") as? UUID{
                        self.idArray.append(newId)
                    }
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("Fetch Error!! Table View not load")
        }
    
    }
    
    @objc func addNewData(){
        //navigate to toDetailVC scrren
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //counter the list
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        //cell.textLabel?.text = nameArray[indexPath.row]
        //cell -> hucre
        //tableview icindeki herbirine hucre denir
        //hucrelerde ne gosterecegiz
        var content = cell.defaultContentConfiguration()
        //hucrede textine objenin ismini goster
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        
       return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //go to detailvs
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //prepare -> hazrilnmak
        if segue.identifier == "toDetailsVC" {
            //if equals segue to todetailvc, run the process
            let destination = segue.destination as! DetailsVC
            destination.chosenPainting = selectedPainting
            destination.chosenId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let apDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = apDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Entity")
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0  {
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do {
                                    try context.save()
                                }catch{
                                    print("Error. İs Not delete")
                                }
                                //close for loop
                                break
                            }
                        }
                    }
                }
            }catch{
                print("Eroor!!")
            }
        }
    }
}

