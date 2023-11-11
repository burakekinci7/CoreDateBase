//
//  DetailsVC.swift
//  CoreDateBase
//
//  Created by Ramazan Burak Ekinci on 8.11.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    var chosenPainting = ""
    var chosenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //call func
        isChosen()
        
        //* Hide keyboard beacuse not scroll
        // Gesture - tap the space screen
        let gestureReg = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureReg)
        
        //* Image picker
        // tap to image
        imageView.isUserInteractionEnabled = true
        let imageRacognizer = UITapGestureRecognizer(target: self, action: #selector(tapImage))
        imageView.addGestureRecognizer(imageRacognizer)
        
      
    }
    
    func isChosen(){
        if chosenPainting != "" {
            saveButtonOutlet.isHidden = true
            //Core data
            let apDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = apDelegate.persistentContainer.viewContext
            //fetch to id
            let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Entity")
            let idString = chosenId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    //Is there an elemets in the list
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("Eroor. isChosen not fetch")
            }
        }else{
            saveButtonOutlet.isHidden = false
            saveButtonOutlet.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
    }
    
    @IBAction func saveOnClick(_ sender: Any) {
        //save button on click:
        
        //Access to AppDelegate Class
        let apDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = apDelegate.persistentContainer.viewContext
        
        //Access to database
        let newPaint = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context)
        //add to attribute - add value - to database
        newPaint.setValue(nameText.text!, forKey: "name")
        newPaint.setValue(artistText.text!, forKey: "artist")
        if let year = Int(yearText.text!){
            //if enter to string, throw exception
            newPaint.setValue(year, forKey: "year")
        }
        newPaint.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPaint.setValue(data, forKey: "image")
   
        //save data
        do{
            try context.save()
            print("Success!")
        }catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapImage(){
        //select to image from gallery
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //did finish picker
        imageView.image = info [.originalImage] as? UIImage
        saveButtonOutlet.isEnabled = true
        self.dismiss(animated: true,completion: nil)
        
    }
    
    @objc func hideKeyboard(){
        //selector.
        // end the scrren
        view.endEditing(true)
    }
}
