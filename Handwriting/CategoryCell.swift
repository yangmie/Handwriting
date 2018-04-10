//
//  CategoryCell.swift
//  Handwriting
//
//  Created by 楊育宗 on 2018/4/10.
//  Copyright © 2018年 楊育宗. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var layerView: UIView!

    override func draw(_ rect: CGRect) {
        self.layerView.layer.masksToBounds = true
        self.layerView.layer.cornerRadius = 8.0
        self.layerView.layer.borderWidth = 1.0
        self.layerView.layer.borderColor = UIColor_Yang(rgb: 0x333333, alpha: 0.15).cgColor
    }
}
