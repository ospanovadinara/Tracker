//
//  TabItem.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit

enum TabItem: Int {
    case tracker
    case statistics

    var image: UIImage? {
        switch self {
        case .tracker: return UIImage(named: "tracker_label_inactive")
        case .statistics: return UIImage(named: "statistics_label_inactive")
        }
    }

    var selectedImage: UIImage? {
        switch self {
        case .tracker: return UIImage(named: "tracker_label_active")
        case .statistics: return UIImage(named: "statistics_label_active")
        }
    }
}
