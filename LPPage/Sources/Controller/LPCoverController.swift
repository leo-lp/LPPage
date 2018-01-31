//
//  LPCoverController.swift
//  LPPage
//
//  Created by lipeng on 2017/11/13.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public enum LPCoverStyle {
    case normal
    case stretch // Cover的背景图片会拉伸
}

open class LPCoverController: LPPageBarController, LPCoverControllerDelegate {
    
    // MARK: - Public Property
    
    /// 往下拉pageBar.frame.origin.y的最大值
    open lazy var maxYPullDown: CGFloat = UIScreen.lp_height
    
    /// 往上拉pageBar.frame.origin.y的最小值（默认为navbar+statusbar的高度）
    open lazy var minYPullUp: CGFloat = lp_topSafeArea
    
    // MARK: - Private Property
    
    private var coverView: UIView?
    
    deinit {
        #if DEBUG
            print("LPCoverController -> relese memory.")
        #endif
    }
    
    open override func viewDidLoad() {
        pageController.coverDelegate = self
        super.viewDidLoad()
        
        guard let cover = viewOfCover(in: self) else { return }
        cover.frame = frameOfCover(in: self)
        view.addSubview(cover)
        coverView = cover
    }
    
    // MARK: - Open Func
    
    open func viewOfCover(in coverController: LPCoverController) -> UIView? {
        return nil
    }
    
    open func frameOfCover(in coverController: LPCoverController) -> CGRect {
        return .zero
    }
    
    open override func frameOfBar(in pageBarController: LPPageBarController) -> CGRect {
        let y = frameOfCover(in: self).maxY
        return CGRect(x: 0, y: y, width: UIScreen.lp_width, height: 40.0)
    }
    
    open override func frameOfPage(in pageBarController: LPPageBarController) -> CGRect {
        return CGRect(x: 0, y: 0, width: UIScreen.lp_width, height: UIScreen.lp_height)
    }
    
    open var coverStyle: LPCoverStyle {
        return .stretch
    }
    
    open override func pageController(_ pageController: LPPageController, originYForSubViewAt index: LPIndex) -> CGFloat {
        if let ctr = pageController.controller(at: index)
            , let dataSource = ctr as? LPPageChildControllerDataSource
            , let _ = dataSource.scrollView(for: pageController)  {
            return 0.0
        }
        return pageBar?.frame.maxY ?? 0.0
    }
    
    /// 交互切换回调
    open override func pageController(_ pageController: LPPageController, willTransitionFrom fromVC: UIViewController, to toVC: UIViewController) {
        changeOffset(to: toVC, isDelay: false)
    }
    
    open override func pageController(_ pageController: LPPageController, didTransitionFrom fromVC: UIViewController, to toVC: UIViewController) {
        pageControllerDidTransition(to: toVC, from: fromVC)
        super.pageController(pageController, didTransitionFrom: fromVC, to: toVC)
    }
    
    /// 非交互切换回调
    open override func pageController(_ pageController: LPPageController, willLeaveFrom fromVC: UIViewController, to toVC: UIViewController) {
        changeOffset(to: toVC, isDelay: false)
    }
    
    open override func pageController(_ pageController: LPPageController, didLeaveFrom fromVC: UIViewController, to toVC: UIViewController) {
        pageControllerDidTransition(to: toVC, from: fromVC)
    }
    
    // MARK: - LPCoverControllerDelegate
    
    open func pageController(_ pageController: LPPageController, topInsetForSubScrollViewAt index: LPIndex) -> CGFloat {
        let topInset = frameOfBar(in: self).maxY - frameOfPage(in: self).origin.y
        let coverMaxY = frameOfCover(in: self).maxY
        
        print("topInset > coverMaxY ? topInset : coverMaxY = \(topInset > coverMaxY ? topInset : coverMaxY)")
        return topInset > coverMaxY ? topInset : coverMaxY
    }
    
    open func pageController(_ pageController: LPPageController, verticalScrollWithPageOffset realOffset: CGFloat, at index: LPIndex) {
        /// 设置PageBar的Origin.y
        changePageBarOriginY(withOffset: realOffset, at: index)
        /// 设置CoverView的Origin.y
        changeCoverViewOriginY(withOffset: realOffset, at: index)
    }
}

// MARK: - Private Func

extension LPCoverController {
    
    private func changePageBarOriginY(withOffset realOffset: CGFloat, at index: LPIndex) {
        let offset = realOffset + self.pageController(pageController, topInsetForSubScrollViewAt: index)
        var top = frameOfBar(in: self).origin.y - offset
        
        if offset >= 0 { /// 上滑
            if top <= minYPullUp {
                top = minYPullUp
            }
        } else { /// 下拉
            if top >= maxYPullDown {
                top = maxYPullDown
            }
        }
        pageBar?.frame.origin.y = top
    }
    
    private func changeCoverViewOriginY(withOffset realOffset: CGFloat, at index: LPIndex) {
        guard let coverView = coverView else { return }
        var offset = realOffset + self.pageController(pageController, topInsetForSubScrollViewAt: index)
        let barY = frameOfBar(in: self).origin.y
        var top = barY - offset
        if offset >= 0.0 {
            if top <= minYPullUp {
                top = minYPullUp
            }
        } else {
            if top >= maxYPullDown {
                top = maxYPullDown
            }
        }
        
        offset = barY - top
        
        let coverFrame = frameOfCover(in: self)
        if coverStyle == .stretch {
            let coverHeight = coverFrame.height - offset
            if coverHeight >= 0.0 {
                coverView.frame.size.height = coverHeight
            } else {
                coverView.frame.size.height = 0.0
            }
        } else {
            let coverTop = coverFrame.origin.y - offset
            if coverTop >= coverFrame.origin.y - coverFrame.height {
                coverView.frame.origin.y = coverTop
            } else {
                coverView.frame.origin.y = coverFrame.origin.y - coverFrame.height
            }
        }
    }
    
    private func changeOffset(to toVC: UIViewController, isDelay: Bool) {
        if numberOfControllers(in: pageController) <= 1 {
            return
        }
        if let toCtr = toVC as? UIViewController & LPPageChildControllerDataSource
            , let scrollView = toCtr.scrollView(for: pageController)
            , let newIndex = pageController.index(of: toCtr) {
            
            let scrollOffset = scrollViewOffset(at: newIndex)
            let topInset = pageController(pageController, topInsetForSubScrollViewAt: newIndex)
            let offset = scrollView.contentOffset.y + topInset
            var top = frameOfBar(in: self).origin.y - offset

            if offset >= 0 { /// 上滑
                if top <= minYPullUp {
                    top = minYPullUp
                }
            } else { /// 下拉
                if top >= maxYPullDown {
                    top = maxYPullDown
                }
            }

            /// 如果计算出来的高度一样，不用去修改offset
            if top != (pageBar?.frame.origin.y ?? 0.0) {
                if isDelay {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let `self` = self else { return }
                        self.cannotScrollWithPageOffset = false
                        scrollView.contentOffset = CGPoint(x: 0, y: scrollOffset)
                    }
                } else {
                    cannotScrollWithPageOffset = false
                    scrollView.contentOffset = CGPoint(x: 0, y: scrollOffset)
                }
            } else {
                cannotScrollWithPageOffset = false
            }
        }
    }
    
    private func pageControllerDidTransition(to toVC: UIViewController, from fromVC: UIViewController) {
        if let dataSource = fromVC as? LPPageChildControllerDataSource
            , let scrollView = dataSource.scrollView(for: pageController) {
            scrollView.scrollsToTop = false
        }

        if let dataSource = toVC as? LPPageChildControllerDataSource
            , let scrollView = dataSource.scrollView(for: pageController) {
            scrollView.scrollsToTop = true
        }

        if cannotScrollWithPageOffset {
            changeOffset(to: toVC, isDelay: true)
        }
    }

    private func scrollViewOffset(at index: LPIndex) -> CGFloat {
        guard let bar = pageBar else { return 0.0 }
        let frame = frameOfBar(in: self)
        let topInset = pageController(pageController, topInsetForSubScrollViewAt: index)
        return frame.origin.y - bar.frame.origin.y - topInset
    }
}
