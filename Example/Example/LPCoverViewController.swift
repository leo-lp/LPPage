//
//  LPCoverViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/20.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit
import LPPage

protocol AAaaa {
    func aaaa(aa : UIPageViewControllerDataSource, bb: UIPageViewControllerDelegate)
}


class LPCoverViewController: LPCoverController {
    deinit {
        #if DEBUG
            print("LPCoverViewController -> relese memory.")
        #endif
    }
    
    var data: LPModel.LPData?
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
        return 8
    }
    
    override func pageBar(_ pageBar: LPPageBar, titleForItemAt index: LPIndex) -> String? {
        return "Item-\(index)"
    }
    
    override func pageController(_ pageController: LPPageController, viewControllerAt index: LPIndex) -> UIViewController? {
        print("创建新ChildViewController, index=\(index)")
        if index % 2 != 0 {
            return LPSubViewController(nibName: "LPSubViewController", bundle: nil)
        } else {
            return LPSubTableViewController(nibName: "LPSubTableViewController", bundle: nil)
        }
    }
    
    override func viewOfCover(in coverController: LPCoverController) -> UIView? {
        return UIImageView(image: UIImage(named: "girl-cover.jpg"))
    }
    
    override func frameOfCover(in coverController: LPCoverController) -> CGRect {
        print("lp_topSafeArea=\(lp_topSafeArea)")
        return CGRect(x: 0, y: lp_topSafeArea, width: UIScreen.lp_width, height: 200)
    }
    
//    /// 如果底部运用了安全区域(safeAreaLayoutGuide)自动布局，则在计算SubScrollView的topInset时需要手动减去topSafeArea个高度
//    override func pageController(_ pageController: LPPageController, topInsetForSubScrollViewAt index: LPIndex) -> CGFloat {
//        let topInset = super.pageController(pageController, topInsetForSubScrollViewAt: index)
//        return topInset - lp_topSafeArea
//    }
    
}
