//
//  ViewController.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit

struct Category {
    var categoryName: String
    var categoryImage: UIImage?
}

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var categoryArray = [Category]()
    var fullScreenSize :CGSize!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Handwriting"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addCategoryAction(sender:)))
        self.navigationController?.navigationBar.barTintColor = UIColor_Yang.init(rgb: 0x8fabd8, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        fullScreenSize = UIScreen.main.bounds.size
    }

    @IBAction func addCategoryAction(sender: Any) {
        let alertController = UIAlertController(title: "New Category", message: "Please enter new category name", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "My Handwriting"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let textField = alertController.textFields![0] as UITextField
            if textField.text!.count > 0 {
                print("Input string is \(textField.text!)")
                self.categoryArray.append(Category(categoryName: textField.text!, categoryImage: nil))
                self.collectionView.reloadData()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(fullScreenSize.width)/2 - 20.0, height: CGFloat(fullScreenSize.width)/2 - 20.0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CategoryCell.self), for: indexPath) as! CategoryCell

        let category = self.categoryArray[indexPath.row]
        cell.nameLabel.text = category.categoryName

        return cell
    }
}
