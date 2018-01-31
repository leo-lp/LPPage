//
//  LPMainViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/17.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

class LPMainViewController: UITableViewController {
    deinit {
        #if DEBUG
            print("LPMainViewController -> relese memory.")
        #endif
    }
    
    var models: [LPModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        models += LPModel.list
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LPMainCell", for: indexPath)
        let data = models[indexPath.section].data[indexPath.row]
        cell.textLabel?.text = data.title
        cell.textLabel?.textColor = data.ok ? #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) : #colorLiteral(red: 1, green: 0.1490196078, blue: 0, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        func push(_ vc: UIViewController) {
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        
        let data = models[indexPath.section].data[indexPath.row]
        switch data.id {
        case .indicator: push(LPIndicatorViewController(data: data))
        case .bar: push(LPPageBarViewController(data: data))
        case .cover: push(LPCoverViewController(data: data))
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
