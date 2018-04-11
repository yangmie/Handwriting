//
//  ViewController.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit
import CoreData

struct Category {
    var categoryName: String
    var categoryImage: UIImage?
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var appDelegate: AppDelegate!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!

    var categoryArray = [Category]()
    var fullScreenSize: CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        context = container.viewContext

        fullScreenSize = UIScreen.main.bounds.size

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addCategoryAction(sender:)))
        navigationController?.navigationBar.tintColor = UIColor.black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Handwriting"
        fetchCategories()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.title = ""
    }

    func fetchCategories() {
        let fetchRequest = NSFetchRequest<CategoryData>(entityName: "CategoryData")
        let descriptor = NSSortDescriptor(key: "categoryName", ascending: true)
        fetchRequest.sortDescriptors = [descriptor]

        do {
            let categories = try context.fetch(fetchRequest)

            categoryArray = []
            for c in categories {
                if let filePath = c.filePath {
                    let contentsOfFilePath = UIImage(contentsOfFile: filePath)
                    categoryArray.append(Category(categoryName: c.categoryName!, categoryImage: contentsOfFilePath))
                } else {
                    categoryArray.append(Category(categoryName: c.categoryName!, categoryImage: nil))
                }

            }
            collectionView.reloadData()
        } catch {
            print("entered catch for categories fetch request")
        }
    }

    func saveCategory(name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "CategoryData", in: context)
        let newCategory = NSManagedObject(entity: entity!, insertInto: context)
        newCategory.setValue(name, forKey: "categoryName")

        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }

    @IBAction func addCategoryAction(sender: Any) {
        let alertController = UIAlertController(title: "New Category", message: "Please enter new category name", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "My Handwriting"
        }

        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            if textField.text!.count > 0 {
                self.saveCategory(name: textField.text!)
                self.fetchCategories()
            }
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(fullScreenSize.width)/2 - 20.0, height: CGFloat(fullScreenSize.width)/2*1.1)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryCell.self), for: indexPath) as! CategoryCell

        let category = categoryArray[indexPath.row]
        cell.nameLabel.text = category.categoryName
        cell.coverImageView.image = category.categoryImage

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categoryArray[indexPath.row]

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let galleryVC = mainStoryboard.instantiateViewController(withIdentifier: String(describing: GalleryViewController.self)) as! GalleryViewController
        galleryVC.categoryName = category.categoryName
        navigationController?.pushViewController(galleryVC, animated: true)
    }
}
