//
//  UserDefaults.swift
//  Tracker
//
//  Created by Dinara on 20.03.2024.
//

import Foundation

extension UserDefaults {
    enum Keys {
        static let isFirstLaunch = "isFirstLaunch"
    }

    var isFirstLaunch: Bool {
        get {
            return bool(forKey: Keys.isFirstLaunch)
        }
        set {
            set(newValue, forKey: Keys.isFirstLaunch)
        }
    }
}
