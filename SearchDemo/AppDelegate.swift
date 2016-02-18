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

        let rootViewController = SearchBarViewController()

        let child = SegmentScrollViewController()
        child.pages = [
            SegmentScrollViewController.Page(title: "First", view: UITableView()),
            SegmentScrollViewController.Page(title: "Second", view: UITableView()),
        ]
        rootViewController.childViewController = child

        let navigationController = UINavigationController(rootViewController: rootViewController)

        let _window = UIWindow()
        _window.rootViewController = navigationController
        _window.makeKeyAndVisible()

        window = _window

        return true
    }
}
