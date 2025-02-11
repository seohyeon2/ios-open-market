//
//  OpenMarket - SceneDelegate.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
        window = UIWindow(windowScene: windowScene)
        
        let isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        if isLoggedIn {
            let mainViewController = MainViewController()
            let navigationController = UINavigationController(rootViewController: mainViewController)
            window?.rootViewController = navigationController
        } else {
            let loginViewController = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginViewController)
            window?.rootViewController = navigationController
        }

        window?.makeKeyAndVisible()
    }
}
