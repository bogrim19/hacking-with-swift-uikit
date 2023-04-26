//
//  ViewController.swift
//  Project10
//
//  Created by Bogrim on 31.03.2023.
//
// using CoreData tutorial from
// https://johncodeos.com/how-to-use-core-data-in-ios-using-swift/

import UIKit
import CoreData

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //var people = [Person]()
    var people = [PeopleData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPeople()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonCell", for: indexPath) as? PersonCell else { fatalError("Can't dequeue a PersonCell.") }
        
        let person = people[indexPath.item]
        cell.PersonName.text = person.personText
        let path = getDocumentsDirectory().appendingPathComponent(String(decoding: person.personImage, as: UTF8.self))
        cell.PersonImage.image = UIImage(contentsOfFile: path.path)
        cell.PersonName.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.PersonImage.layer.borderWidth = 2
        cell.PersonImage.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath) // this thing throws
        }
        
//        let person = PersonData()
//        person.personImage = imageName.data(using: .utf8) ?? Data()
//        person.personText = "Unknown"
//        people.append(person)
        
        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
        let newPerson = PeopleData(context: managedContext)
            newPerson.setValue(imageName.data(using: .utf8) ?? Data(), forKey: #keyPath(PeopleData.personImage))
            newPerson.setValue("Unknown", forKey: #keyPath(PeopleData.personText))
            self.people.insert(newPerson, at: 0)
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        // MARK: Rename or delete prompt
        let choiceAlertController = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .actionSheet)
        choiceAlertController.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            // MARK: Rename cell
            if let self = self {
                self.renamePerson(indexPath: indexPath)
            }
        })
        
        choiceAlertController.addAction(UIAlertAction(title: "Delete", style: .destructive){ [weak self] _ in
            guard let self = self else { return }
            AppDelegate.sharedAppDelegate.coreDataStack.managedContext.delete(self.people[indexPath.item])
            people.remove(at: indexPath.item)
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            self.collectionView.deleteItems(at: [indexPath])
            self.collectionView.reloadData()
        })
        
        present(choiceAlertController, animated: true)
    }
    
    func renamePerson(indexPath: IndexPath) {
        let person = people[indexPath.item]

        let ac = UIAlertController(title: "Rename Person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.personText = newName
            self?.people[indexPath.item].setValue(newName, forKey: #keyPath(PeopleData.personText))
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            self?.collectionView.reloadData()
            }
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(ac, animated: true)
    }
    
    func getPeople() {
        /*
         let noteFetch: NSFetchRequest<Note> = Note.fetchRequest()
             let sortByDate = NSSortDescriptor(key: #keyPath(Note.dateAdded), ascending: false)
             noteFetch.sortDescriptors = [sortByDate]
             do {
                 let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
                 let results = try managedContext.fetch(noteFetch)
                 notes = results
             } catch let error as NSError {
                 print("Fetch error: \(error) description: \(error.userInfo)")
             }
         */
        let peopleFetch: NSFetchRequest<PeopleData> = PeopleData.fetchRequest()
        do {
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let results = try managedContext.fetch(peopleFetch)
            people = results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
}

