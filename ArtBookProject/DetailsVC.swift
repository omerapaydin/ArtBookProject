//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Ömer on 25.12.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if chosenPainting != ""{
            
            saveButton.isHidden = true
            
            
           
            let appDel = UIApplication.shared.delegate as! AppDelegate
            let context = appDel.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Painting")
            
            let idString = chosenPaintingId?.uuidString
            fetch.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetch.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetch)
                
                for result in results as! [NSManagedObject]{
                    
                    if let name = result.value(forKey: "name") as? String {
                        nameText.text = name
                    }
                    if let artist = result.value(forKey: "artist") as? String {
                        artistText.text = artist
                    }
                    if let year = result.value(forKey: "year") as? Int {
                        yearText.text = String(year)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                        imageView.image = image
                        
                    }
                   
                }
           
                
            } catch{
                print("error")
            }
            
            
            
        }else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
       
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(ges)
        
        imageView.isUserInteractionEnabled = true
        let gesImage = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(gesImage)
        
        
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true)
        
    }
    
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
 
    @IBAction func save(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let newAdd = NSEntityDescription.insertNewObject(forEntityName: "Painting", into: context)
        
        newAdd.setValue(nameText.text!, forKey: "name")
        newAdd.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newAdd.setValue(year, forKey: "year")
        }
        
        newAdd.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newAdd.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
