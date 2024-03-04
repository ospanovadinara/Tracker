//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        if UserDefaults.standard.value(forKey: "OnboardingHasLaunchedBefore") == nil {
            window?.rootViewController = OnboardingPageViewController()
        } else {
            window?.rootViewController = MainTabBarViewController()
        }

        window?.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        DataManager.shared.saveContext()
    }
}

