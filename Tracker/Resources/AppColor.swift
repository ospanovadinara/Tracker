//
//  AppColor.swift
//  Tracker
//
//  Created by Dinara on 19.01.2024.
//

import UIKit

protocol AppColorProtocol {
    var rawValue: String { get }
}

extension AppColorProtocol {

    var uiColor: UIColor {
        UIColor.init(named: rawValue) ?? .white
    }

    var cgColor: CGColor {
        return uiColor.cgColor
    }
}

enum AppColor: String, AppColorProtocol {
    case color1 = "Color1"
    case color2 = "Color2"
    case color3 = "Color3"
    case color4 = "Color4"
    case color5 = "Color5"
    case color6 = "Color6"
    case color7 = "Color7"
    case color8 = "Color8"
    case color9 = "Color9"
    case color10 = "Color10"
    case color11 = "Color11"
    case color12 = "Color12"
    case color13 = "Color13"
    case color14 = "Color14"
    case color15 = "Color15"
    case color16 = "Color16"
    case color17 = "Color17"
    case color18 = "Color18"
}
