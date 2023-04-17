//
//  CALayer + extension.swift
//  OpenMarket
//
//  Created by seohyeon park on 2023/04/09.
//

import UIKit

extension CALayer {
    func addBorder(frame: CGRect) {
        let border = CALayer()
        border.backgroundColor = UIColor.primary?.cgColor
        border.frame = frame
        self.addSublayer(border)
    }
}
