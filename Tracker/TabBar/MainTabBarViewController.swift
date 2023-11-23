//
//  MainTabBarViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        view.backgroundColor = .systemBackground
        let tracker = UINavigationController(rootViewController: MainTrackerViewController())
        let statistics = UINavigationController(rootViewController: MainStatisticsViewController())
        tracker.tabBarItem = tabItem(for: .tracker, title: "Трекеры")
        statistics.tabBarItem = tabItem(for: .statistics, title: "Статистика")
        setViewControllers([tracker, statistics], animated: true)
        selectedIndex = 0

        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.systemGray5.cgColor
    }

    private func tabItem(for type: TabItem, title: String) -> UITabBarItem {
        let item = UITabBarItem(title: title,
                                image: type.image,
                                selectedImage: type.selectedImage)
        return item
    }
}
