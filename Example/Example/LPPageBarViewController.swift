//
//  LPPageBarViewController.swift
//  Example
//
//  Created by lipeng on 2017/11/20.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit
import LPPage

class LPPageBarViewController: LPBasePageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var isShowInNavBarForPageBar: Bool {
        guard let data = data, case .bar(let type) = data.id else { return false }
        return LPBar.showInNavBar == type
    }
    
    override func customPageBar(in pageBarController: LPPageBarController) -> UIView? {
        if let data = data, case .bar(let type) = data.id {
            if type == .custom {
                let frame = self.frameOfBar(in: self)
                let segCtr = UISegmentedControl(items: titles)
                segCtr.frame = frame
                segCtr.layer.borderColor = UIColor.red.cgColor
                segCtr.layer.borderWidth = 2
                segCtr.selectedSegmentIndex = defaultSelectPageAtIndex()
                segCtr.addTarget(self, action: #selector(segCtrValueChanged), for: .valueChanged)
                return segCtr
            } else if type == .none {
                return nil
            }
        }
        return super.customPageBar(in: pageBarController)
    }
    
    override func frameOfBar(in pageBarController: LPPageBarController) -> CGRect {
        if let data = data, case .bar(let type) = data.id, type == .none {
            return .zero
        }
        return super.frameOfBar(in: self)
    }
    
    override func defaultSelectPageAtIndex() -> LPIndex {
        return 0
    }
    
    @objc func segCtrValueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        pageController.showPage(at: index, animated: true)
    }
    
    // MARK: - LPPageControllerDelegate
    
    /// 横向滑动回调
    override func pageController(_ pageController: LPPageController, pageViewContentOffset ratio: CGFloat, draging: Bool) {
        if let data = data, case .bar(let type) = data.id, type == LPBar.custom {
            if !draging { return }
            guard let pageBar = pageBar, pageBar is UISegmentedControl else { return }
            let segCtr = pageBar as! UISegmentedControl
            let index = LPIndex(floor(ratio + 0.5))
            if index != segCtr.selectedSegmentIndex {
                segCtr.selectedSegmentIndex = index
            }
            return
        }
        super.pageController(pageController, pageViewContentOffset: ratio, draging: draging)
    }
    
    override func pageController(_ pageController: LPPageController, didTransitionFrom fromVC: UIViewController, to toVC: UIViewController) {
        if let data = data, case .bar(let type) = data.id, type == LPBar.custom {
            guard let pageBar = pageBar, pageBar is UISegmentedControl else { return }
            let segCtr = pageBar as! UISegmentedControl
            let index = pageController.selectedIndex
            if index != segCtr.selectedSegmentIndex {
                segCtr.selectedSegmentIndex = index
            }
            return
        }
        super.pageController(pageController, didTransitionFrom: fromVC, to: toVC)
    }
}
