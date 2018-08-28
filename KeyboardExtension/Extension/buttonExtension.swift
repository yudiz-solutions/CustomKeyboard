//
//  LabelExtension.swift
//  KeyboardExtension
//
//  Created by Yudiz Solutions Pvt. Ltd. on 20/08/18.
//  Copyright © 2018 Yudiz Solution Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit

class ShadowButton: UIButton{

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareUI()
    }
    
    func prepareUI() {
        layer.cornerRadius = 5
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.masksToBounds = false
    }
}
