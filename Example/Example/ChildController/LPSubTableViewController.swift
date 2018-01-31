//
//  LPSubTableViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/17.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit
import LPPage

class LPSubTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        #if DEBUG
            print("LPSubTableViewController -> relese memory.")
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LPSubTableViewController - > viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LPSubTableViewController - > viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LPSubTableViewController - > viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("LPSubTableViewController - > viewDidDisappear")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        
        tableView.layer.borderColor = UIColor.blue.cgColor
        tableView.layer.borderWidth = 2
    }
}

extension LPSubTableViewController: LPPageChildControllerDataSource {
    func scrollView(for pageController: LPPageController) -> UIScrollView? {
        return tableView
    }
}

extension LPSubTableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LPSubTableCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "LPSubTableCell")
        }
        cell?.textLabel?.text = "\(view.tag)-Row-\(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LPMainSBID")
        navigationController?.pushViewController(vc, animated: true)
    }
}
