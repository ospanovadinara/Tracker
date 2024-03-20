//
//  UITextField.swift
//  Tracker
//
//  Created by Dinara on 20.03.2024.
//

import UIKit


extension UITextField {
    func setupLeftView(size: CGFloat) {
        self.leftView = UIView(
            frame:
                CGRect(
                    x: self.frame.minX,
                    y: self.frame.minY,
                    width: size,
                    height: self.frame.height
                )
        )
        self.leftViewMode = .always
    }
}
