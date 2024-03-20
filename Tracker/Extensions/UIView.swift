//
//  UIView.swift
//  Tracker
//
//  Created by Dinara on 20.03.2024.
//

import UIKit

extension UIView {
    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func addGradienBorder(
        colors: [UIColor],
        width: CGFloat,
        startPoint: CGPoint = CGPoint(x: 0, y: 0.5),
        endPoint: CGPoint = CGPoint(x: 1, y: 0.5)
    ) {
        let existingBorder = gradientBorderLayer()
        let border = existingBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        mask.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        ).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let isAlreadyAdded = existingBorder != nil
        if !isAlreadyAdded {
            layer.addSublayer(border)
        }
    }

    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter {
            $0.name == UIView.kLayerNameGradientBorder
        }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }

    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
}
