//
//  AppDelegate.swift
//  SearchDemo
//
//  Created by Giovanni on 29/01/2016.
//  Copyright © 2016 Umbrella. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        guard let window = window else {
            fatalError()
        }

        let rootViewController = StartViewController()

        let child = SearchViewController()
        child.pages = [
            SearchViewController.Page(title: "First", view: UITableView()),
            SearchViewController.Page(title: "Second", view: UITableView()),
        ]
        rootViewController.childViewController = child

        let navigationController = UINavigationController(rootViewController: rootViewController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        return true
    }
}
