//
//  LPTabController.swift
//  LPPage
//
//  Created by lipeng on 2017/11/3.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

open class LPPageBarController: UIViewController
, LPPageControllerDataSource
, LPPageControllerDelegate
, LPPageBarDataSource
, LPPageBarDelegate
, LPIndicatorViewDataSource {
    
    // MARK: - Private(set) Property
    
    public private(set) var pageBar: UIView?
    public private(set) var pageController: LPPageController = LPPageController()
    
    internal(set) var cannotScrollWithPageOffset: Bool = false // 为解决pagecontroller的横向滑动问题
    
    deinit {
        #if DEBUG
            print("LPPageBarController -> relese memory.")
        #endif
    }
    
    // MARK: - Override Func
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cannotScrollWithPageOffset = false
        pageController.beginAppearanceTransition(true, animated: animated)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageController.endAppearanceTransition()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cannotScrollWithPageOffset = true
        pageController.beginAppearanceTransition(false, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageController.endAppearanceTransition()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupPage()
        setupBar()
    }
    
    // MARK: - Open Func
    
    open var isShowInNavBarForPageBar: Bool {
        return false
    }
    
    open func customPageBar(in pageBarController: LPPageBarController) -> UIView? {
        let frame = self.frameOfBar(in: self)
        return LPPageBar(frame: frame, dataSource: self, delegate: self, indicatorDalegate: self)
    }
    
    open func frameOfBar(in pageBarController: LPPageBarController) -> CGRect {
        let y = isShowInNavBarForPageBar ? 0.0 : lp_topSafeArea
        return CGRect(x: 0.0, y: y, width: UIScreen.lp_width, height: 40.0)
    }
    
    open func frameOfPage(in pageBarController: LPPageBarController) -> CGRect {
        let barFrame = frameOfBar(in: self)
        var y = barFrame.maxY
        if isShowInNavBarForPageBar || barFrame == .zero {
            y = lp_topSafeArea
        }
        return CGRect(x: 0, y: y, width: UIScreen.lp_width, height: UIScreen.lp_height - y)
    }
    
    open func defaultSelectPageAtIndex() -> LPIndex {
        return 0
    }
    
    // MARK: - LPIndicatorViewDataSource
    
    open func styleForIndicatorView(in pageBar: LPPageBar) -> LPIndicatorStyle? {
        return .stripe(.textWidth(LPStripeFrame()), UIColor.orange)
    }
    
    // MARK: - LPPageBarDataSource
    
    open func pageBar(_ pageBar: LPPageBar, titleForItemAt index: LPIndex) -> String? {
        return nil
    }
    
    open func itemLeftOffset(for pageBar: LPPageBar) -> CGFloat {
        return 5.0
    }
    
    open func numberOfItems(in pageBar: LPPageBar) -> LPIndex {
        return numberOfControllers(in: pageController)
    }
    
    open func pageBar(_ pageBar: LPPageBar, widthForItemAt index: LPIndex) -> CGFloat {
        return 73.0
    }
    
    open func pageBar(_ pageBar: LPPageBar, topForItemAt index: LPIndex) -> CGFloat {
        return 0.0
    }
    
    open func pageBar(_ pageBar: LPPageBar, colorForTitleAt index: LPIndex) -> UIColor {
        return UIColor.black
    }
    
    open func pageBar(_ pageBar: LPPageBar, colorForSelectTitleAt index: LPIndex) -> UIColor {
        return UIColor.orange
    }
    
    open func pageBar(_ pageBar: LPPageBar, fontForTitleAt index: LPIndex) -> UIFont {
        return UIFont.systemFont(ofSize: 13.0)
    }
    
    public func defaultSelectedIndex(in pageBar: LPPageBar) -> LPIndex {
        return defaultSelectPageAtIndex()
    }
    
    // MARK: - LPPageBarDelegate
    
    open func pageBar(_ pageBar: LPPageBar, didSelectItemAt index: LPIndex) {
        pageController.showPage(at: index, animated: true)
    }
    
    // MARK: - LPPageControllerDataSource
    
    open func numberOfControllers(in pageController: LPPageController) -> LPIndex {
        return 0
    }
    
    open func pageController(_ pageController: LPPageController, viewControllerAt index: LPIndex) -> UIViewController? {
        return nil
    }
    
    /// 解决侧滑失效的问题
    public func screenEdgePanGestureRecognizer(in pageController: LPPageController) -> UIScreenEdgePanGestureRecognizer? {
        if let nav = navigationController
            , let recognizers = nav.view.gestureRecognizers
            , recognizers.count > 0 {
            for recognizer in recognizers where recognizer is UIScreenEdgePanGestureRecognizer {
                return recognizer as? UIScreenEdgePanGestureRecognizer
            }
        }
        return nil
    }
    
    /// 交互切换的时候 是否预加载
    open func isPreLoad(in pageController: LPPageController) -> Bool {
        return true
    }
    
    open func pageController(_ pageController: LPPageController, originYForSubViewAt index: LPIndex) -> CGFloat {
        return 0.0
    }
    
    // MARK: - LPPageControllerDelegate
    
    /// 交互切换回调
    open func pageController(_ pageController: LPPageController, willTransitionFrom fromVC: UIViewController, to toVC: UIViewController) {
    }
    
    open func pageController(_ pageController: LPPageController, didTransitionFrom fromVC: UIViewController, to toVC: UIViewController) {
        guard let pageBar = pageBar, pageBar is LPPageBar else { return }
        let bar = pageBar as! LPPageBar
        bar.scrollItem(to: pageController.selectedIndex)
    }
    
    /// 非交互切换回调
    open func pageController(_ pageController: LPPageController, willLeaveFrom fromVC: UIViewController, to toVC: UIViewController) {
    }
    
    open func pageController(_ pageController: LPPageController, didLeaveFrom fromVC: UIViewController, to toVC: UIViewController) {
    }
    
    /// 横向滑动回调
    open func pageController(_ pageController: LPPageController, pageViewContentOffset ratio: CGFloat, draging: Bool) {
        guard let pageBar = pageBar, pageBar is LPPageBar else { return }
        let bar = pageBar as! LPPageBar
        if draging {
            bar.indicatorViewScroll(toContentRatio: ratio)
            bar.reloadHighlight(to: LPIndex(floor(ratio + 0.5)))
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                bar.indicatorViewScroll(to: LPIndex(ratio))
                bar.canMoveIndicator = false
            }, completion: { (finished) in
                bar.canMoveIndicator = true
                bar.reloadHighlight(to: LPIndex(floor(ratio + 0.5)))
            })
        }
    }
    
    public func willChangeInit(in pageController: LPPageController) {
        cannotScrollWithPageOffset = true
    }
    
    public func cannotScrollWithPageOffset(in pageController: LPPageController) -> Bool {
        return cannotScrollWithPageOffset
    }
}

// MARK: - Private Setup Func

extension LPPageBarController {
    
    private func setupPage() {
        pageController.dataSource = self
        pageController.delegate = self
        pageController.selectedIndex = defaultSelectPageAtIndex()
        pageController.view.frame = frameOfPage(in: self)
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
    }
    
    private func setupBar() {
        guard let bar = customPageBar(in: self) else { return }
        if isShowInNavBarForPageBar {
            navigationItem.titleView = bar
        } else {
            view.addSubview(bar)
        }
        pageBar = bar
    }
}
