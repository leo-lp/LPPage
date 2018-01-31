//
//  LPPageControllerProtocol.swift
//  LPPage
//
//  Created by lipeng on 2017/11/3.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public protocol LPPageControllerDataSource: NSObjectProtocol {
    func numberOfControllers(in pageController: LPPageController) -> LPIndex
    func pageController(_ pageController: LPPageController, viewControllerAt index: LPIndex) -> UIViewController?
    
    /// 解决侧滑失效的问题
    func screenEdgePanGestureRecognizer(in pageController: LPPageController) -> UIScreenEdgePanGestureRecognizer?
    
    /// 交互切换的时候 是否预加载
    func isPreLoad(in pageController: LPPageController) -> Bool
    
    /// 用于设置子controller的View.frame.origin.y
    func pageController(_ pageController: LPPageController, originYForSubViewAt index: LPIndex) -> CGFloat
}

public protocol LPPageControllerDelegate: NSObjectProtocol {
    /// 交互切换回调
    func pageController(_ pageController: LPPageController, willTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> Void
    func pageController(_ pageController: LPPageController, didTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> Void
    
    /// 非交互切换回调
    func pageController(_ pageController: LPPageController, willLeaveFrom fromVC: UIViewController, to toVC: UIViewController) -> Void
    func pageController(_ pageController: LPPageController, didLeaveFrom fromVC: UIViewController, to toVC: UIViewController) -> Void
    
    /// 横向滑动回调
    func pageController(_ pageController: LPPageController, pageViewContentOffset ratio: CGFloat, draging: Bool) -> Void
    
    func willChangeInit(in pageController: LPPageController) -> Void
    func cannotScrollWithPageOffset(in pageController: LPPageController) -> Bool
}
