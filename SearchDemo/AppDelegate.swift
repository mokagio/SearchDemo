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
    let dataSource = DataSource()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let rootViewController = SearchBarViewController()

        let firstTableView = UITableView()
        let secondTableView = UITableView()
        [firstTableView, secondTableView].forEach { t in
            t.registerClass(UITableViewCell.self, forCellReuseIdentifier: dataSource.cellIdentifier)
            t.dataSource = dataSource
        }

        let child = SegmentScrollViewController()
        child.pages = [
            SegmentScrollViewController.Page(title: "First", view: firstTableView),
            SegmentScrollViewController.Page(title: "Second", view: secondTableView),
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

class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    let cellIdentifier = "Cell"

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 16
    }

    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
