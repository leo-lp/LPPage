//
//  LPBasePageViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/20.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit
import LPPage

class LPBasePageViewController: LPPageBarController {
    let titles: [String] = ["热门", "关注-关注", "最新", "热门", "关注-关注", "最新", "热门", "关注-关注", "最新"]
    var data: LPModel.LPData?
    
    deinit {
        #if DEBUG
            print("LPBasePageViewController -> relese memory.")
        #endif
    }
    
    convenience init(data: LPModel.LPData) {
        self.init(nibName: nil, bundle: nil)
        self.data = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = data?.title
        pageBar?.backgroundColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
    }
    
    override func numberOfControllers(in pageController: LPPageController) -> LPIndex {
        return titles.count
    }
    
    override func pageBar(_ pageBar: LPPageBar, titleForItemAt index: LPIndex) -> String? {
        return titles[index]
    }
    
    override func pageController(_ pageController: LPPageController, viewControllerAt index: LPIndex) -> UIViewController? {
        print("创建新ChildViewController, index=\(index)")
        if index % 2 == 0 {
            return LPSubViewController(nibName: "LPSubViewController", bundle: nil)
        } else {
            return LPSubTableViewController(nibName: "LPSubTableViewController", bundle: nil)
        }
    }
    
}
