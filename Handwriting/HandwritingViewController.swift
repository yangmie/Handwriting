//
//  HandwritingViewController.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit
import CoreData

protocol HandwritingViewControllerDelegate {
    func reloadPhotos()
}

class HandwritingViewController: UIViewController, EditHandwritingViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var setCoverButton: UIButton!

    var delegate: HandwritingViewControllerDelegate?

    var appDelegate: AppDelegate!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    var handwriting: Handwriting!

    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        context = container.viewContext

        imageView.image = handwriting.image
        descriptionLabel.text = handwriting.description

        setCoverButton.layer.masksToBounds = true
        setCoverButton.layer.cornerRadius = 5.0

        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deletePhoto))
        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPhoto))
        navigationItem.rightBarButtonItems = [deleteButton, editButton]

        navigationController?.navigationBar.tintColor = UIColor.black
    }

    @IBAction func setCoverPhotoAction(sender: Any) {
        let fetchRequest = NSFetchRequest<CategoryData>(entityName: "CategoryData")
        fetchRequest.predicate = NSPredicate(format: "categoryName = %@", handwriting.categoryName)

        do {
            let categories = try context.fetch(fetchRequest)
            if categories.count > 0 {
                let c = categories.first
                c?.filePath = handwriting.filePath
            }

        } catch {
            print("entered catch for categories fetch request")
        }
    }

    @IBAction func deletePhoto() {
        if let data = handwriting.data {
            context.delete(data)
            do {
                try context.save()
                delegate?.reloadPhotos()
                navigationController?.popViewController(animated: true)
            } catch {
            }
        }
    }

    @IBAction func editPhoto() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addHandwritingVC = mainStoryboard.instantiateViewController(withIdentifier: String(describing: AddHandwritingViewController.self)) as! AddHandwritingViewController
        addHandwritingVC.handwriting = handwriting
        addHandwritingVC.editDelegate = self
        navigationController?.pushViewController(addHandwritingVC, animated: true)
    }

    func reloadHandwriting(handwriting: Handwriting) {
        self.handwriting = handwriting
        descriptionLabel.text = handwriting.description
    }
}
