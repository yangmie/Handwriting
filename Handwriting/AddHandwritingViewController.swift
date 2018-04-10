//
//  AddHandwritingViewController.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit

protocol AddHandwritingViewControllerDelegate {
    func saveHandwriting(handwriting: Handwriting)
}

class AddHandwritingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!

    var delegate: AddHandwritingViewControllerDelegate?

    var handwriting: Handwriting!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveHandwritingAction(sender:)))
        navigationController?.navigationBar.barTintColor = UIColor_Yang.init(rgb: 0x8fabd8, alpha: 1)
        navigationController?.navigationBar.tintColor = UIColor.black

        imageView.image = handwriting.image
        textView.textContainerInset = UIEdgeInsets.zero
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        textView.becomeFirstResponder()
    }

    @IBAction func saveHandwritingAction(sender: Any) {
        handwriting.description = textView.text
        navigationController?.popViewController(animated: true)
        delegate?.saveHandwriting(handwriting: handwriting)
    }
}
