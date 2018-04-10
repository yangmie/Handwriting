//
//  HandwritingViewController.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit
import CoreData

class HandwritingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var setCoverButton: UIButton!

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
    }

    @IBAction func setCoverPhotoAction(sender: Any) {
        let fetchRequest = NSFetchRequest<CategoryData>(entityName: "CategoryData")
        fetchRequest.predicate = NSPredicate(format: "categoryName = %@", handwriting.categoryName)

        do {
            let categories = try context.fetch(fetchRequest)
            if categories.count > 0 {
                let c = categories.first
                c?.setValue(handwriting.filePath, forKey: "filePath")
            }

        } catch {
            print("entered catch for categories fetch request")
        }
    }
}
