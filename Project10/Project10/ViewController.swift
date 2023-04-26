//
//  ViewController.swift
//  Project10
//
//  Created by Bogrim on 31.03.2023.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else { fatalError("Can't dequeue a PersonCell.") }
        
        let person = people[indexPath.item]
        cell.PersonName.text = person.name
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
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
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = people[indexPath.item]
        
        // MARK: Rename or delete prompt
        let choiceAlertController = UIAlertController(title: "", message: "Choose an action", preferredStyle: .alert)
        choiceAlertController.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            // MARK: Rename cell
            if let self = self {
                self.renamePerson(indexPath: indexPath)
            }
        })
        
        choiceAlertController.addAction(UIAlertAction(title: "Delete", style: .destructive){ [weak self] _ in
            guard let self = self else { return }
            people.remove(at: indexPath.item)
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
            person.name = newName
            self?.collectionView.reloadData()
            }
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(ac, animated: true)
    }
}
