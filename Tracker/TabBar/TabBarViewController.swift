//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Ди Di on 23/05/25.
//

import UIKit


final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarFont = UIFont(name: "SFProDisplay-Medium", size: 10)!
        
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: tabBarFont,
            .foregroundColor: UIColor.ypGray
        ], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([
            .font: tabBarFont,
            .foregroundColor: UIColor.ypBlue
        ], for: .selected)
        
        tabBar.layer.shadowColor = UIColor.ypGray.cgColor
        tabBar.layer.borderWidth = 0.3
        tabBar.tintColor = .ypBlue
        
        let trackerViewController = TrackerViewController()
        let trackerNavigation = UINavigationController(rootViewController: trackerViewController)
        trackerNavigation.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_trackers_not_active")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab_trackers_not_active")
        )
        
        let staticticViewController = StaticticViewController()
        let staticticNavigation = UINavigationController(rootViewController: staticticViewController)
        staticticNavigation.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistic_not_active")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab_statistic_not_active")
        )
        viewControllers = [trackerNavigation, staticticNavigation]
    }
}
