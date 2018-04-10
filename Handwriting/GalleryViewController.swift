//
//  GalleryViewController.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit
import CoreData

struct Handwriting {
    var description: String
    var categoryName: String
    var filePath: String
    var image: UIImage
}

class GalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var appDelegate: AppDelegate!
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!

    var handwritingArray = [Handwriting]()
    var categoryName: String!
    var fullScreenSize: CGSize!
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        context = container.viewContext

        fullScreenSize = UIScreen.main.bounds.size
        imagePicker.delegate = self

        title = categoryName!

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addHandwritingAction(sender:)))
        navigationController?.navigationBar.barTintColor = UIColor_Yang.init(rgb: 0x8fabd8, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.black

        fetchHandwritings()
    }

    func fetchHandwritings() {
        let fetchRequest = NSFetchRequest<HandwritingData>(entityName: "HandwritingData")
        fetchRequest.predicate = NSPredicate(format: "categoryName = %@", categoryName!)

        do {
            handwritingArray = []
            let handwritings = try context.fetch(fetchRequest)
            
            for h in handwritings {
                if let filePath = h.filePath {
                    if FileManager.default.fileExists(atPath: filePath) {
                        if let contentsOfFilePath = UIImage(contentsOfFile: filePath) {
                            handwritingArray.append(Handwriting(description: h.desc!, categoryName: categoryName!, filePath: filePath, image: contentsOfFilePath))
                        }
                    }
                }
            }
            collectionView.reloadData()
        } catch {
            print("entered catch for categories fetch request")
        }
    }


}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return handwritingArray.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(fullScreenSize.width)/3 - 1.0, height: CGFloat(fullScreenSize.width)/3 - 1.0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HandwritingCell.self), for: indexPath) as! HandwritingCell

        let handwriting = handwritingArray[indexPath.row]
        cell.imageView.image = handwriting.image

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let handwriting = handwritingArray[indexPath.row]

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let handwritingVC = mainStoryboard.instantiateViewController(withIdentifier: String(describing: HandwritingViewController.self)) as! HandwritingViewController
        handwritingVC.handwriting = handwriting
        navigationController?.pushViewController(handwritingVC, animated: true)
    }
}

extension GalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, AddHandwritingViewControllerDelegate {

    @IBAction func addHandwritingAction(sender: Any) {

        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary() {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true

        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        // Dismiss the view controller a
        picker.dismiss(animated: true, completion: nil)

        // Get the picture we took
        var image = info[UIImagePickerControllerEditedImage] as! UIImage
        image = fixOrientation(img: image)

        let handwriting = Handwriting(description: "", categoryName: "", filePath: "", image: image)
        showAddHandwritingVC(handwriting: handwriting)
    }

    func showAddHandwritingVC(handwriting: Handwriting) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let addHandwritingVC = mainStoryboard.instantiateViewController(withIdentifier: String(describing: AddHandwritingViewController.self)) as! AddHandwritingViewController
        addHandwritingVC.handwriting = handwriting
        addHandwritingVC.delegate = self
        navigationController?.pushViewController(addHandwritingVC, animated: true)
    }

    func saveHandwriting(handwriting: Handwriting) {
        // Save imageData to filePath
        let image = handwriting.image

        // Get access to shared instance of the file manager
        let fileManager = FileManager.default

        // Get the URL for the users home directory
        let documentsURL =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        // Create filePath URL by appending final path component (name of image)

        let filePath = documentsURL.appendingPathComponent("\(randomString(length: 10)).png")

        // Create imageData and write to filePath
        do {
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: filePath, options: .atomic)
            }
        } catch {
            print("couldn't write image")
        }

        // Save filePath and imagePlacement to CoreData
        let entity = NSEntityDescription.entity(forEntityName: "HandwritingData", in: context)
        let newHandwriting = HandwritingData(entity: entity!, insertInto: context)
        newHandwriting.filePath = filePath.path
        newHandwriting.desc = handwriting.description
        newHandwriting.categoryName = categoryName!

        do {
            try context.save()
            fetchHandwritings()
        } catch {
            print("Failed saving")
        }
    }

    func randomString(length: Int) -> String {

        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }

    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
