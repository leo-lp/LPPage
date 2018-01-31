//
//  LPPageController.swift
//  LPPage
//
//  Created by lipeng on 2017/11/3.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public class LPPageController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Public Enum
    
    public enum LPScrollDirection {
        case left, right
    }
    
    // MARK: - Public Property
    
    public var selectedIndex: LPIndex = 0
    
    public weak var delegate: LPPageControllerDelegate?
    public weak var dataSource: LPPageControllerDataSource?
    public weak var coverDelegate: LPCoverControllerDelegate?
    
    // MARK: - Private Property
    
    public private(set) lazy var pageView: LPPageView = LPPageView(frame: self.view.bounds)
    
    private var controllers: [LPIndex: UIViewController] = [:]
    private var lastContentOffset: [LPIndex: CGFloat] = [:]
    private var lastContentSize: [LPIndex: CGFloat] = [:]
    
    private var lastSelectedIndex: LPIndex = 0
    private var guessToIndex: LPIndex = 0
    private var originOffset: CGFloat = 0.0
    
    private var firstWillAppear: Bool = true
    private var firstWillLayoutSubViews: Bool = true
    private var firstDidAppear: Bool = true
    
    // MARK: - Override Func
    
    deinit {
        delegate = nil
        dataSource = nil
        removeCoverObservers()
        controllers.removeAll()
        
        #if DEBUG
            print("LPPageController -> relese memory.")
        #endif
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstWillAppear {
            if let lastVC = controller(at: lastSelectedIndex), let currVC = controller(at: selectedIndex) {
                delegate?.pageController(self, willLeaveFrom: lastVC, to: currVC)
            }
            
            if let edgePan = dataSource?.screenEdgePanGestureRecognizer(in: self)
                ?? screenEdgePanGestureRecognizer() {
                pageView.panGestureRecognizer.require(toFail: edgePan)
            }
            
            firstWillAppear = false
            updatePageViewLayoutIfNeed()
        }
        if let currVC = controller(at: selectedIndex) {
            currVC.beginAppearanceTransition(true, animated: true)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstDidAppear {
            if let delegate = delegate {
                delegate.willChangeInit(in: self)
                if let lastVC = controller(at: lastSelectedIndex)
                    , let currVC = controller(at: selectedIndex) {
                    delegate.pageController(self, didLeaveFrom: lastVC, to: currVC)
                }
            }
            firstDidAppear = false
        }
        if let currVC = controller(at: selectedIndex) {
            currVC.endAppearanceTransition()
        }
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageView.frame = view.bounds
        
        if firstWillLayoutSubViews {
            updatePageViewLayoutIfNeed()
            updatePageViewDisplayIndexIfNeed()
            firstWillLayoutSubViews = false
        } else {
            updatePageViewLayoutIfNeed()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        pageView.delegate = self
        view.addSubview(pageView)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        for item in pageView.subviews {
            item.removeFromSuperview()
        }
        
        lastContentOffset.removeAll()
        lastContentSize.removeAll()
        
        if controllers.count > 0 {
            removeCoverObservers()
            for controller in controllers.values {
                removeFromParentVC(for: controller)
            }
            controllers.removeAll()
        }
        
        #if DEBUG
            print("内存报警 -> 清理 PageViewControllers")
        #endif
    }
    
    public override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    // MARK: - Public Func
    
    /// 用于非交互切换接口
    public func showPage(at index: LPIndex, animated: Bool) {
        if index < 0 || index >= pageCount { return }
        if pageView.frame.width <= 0.0 || pageView.contentSize.width <= 0.0 { return }
        
        let oldSelectIndex = lastSelectedIndex
        lastSelectedIndex = selectedIndex
        selectedIndex = index
        
        if let delegate = delegate {
            delegate.willChangeInit(in: self)
            if let fromVC = controller(at: lastSelectedIndex) , let toVC = controller(at: selectedIndex) {
                delegate.pageController(self, willLeaveFrom: fromVC, to: toVC)
            }
        }
        
        addVisibleController(with: index)
        scrollBeginAnimation(animated)
        
        /// NOTE: 页面切换动画
        /// 如果非交互切换的index和currentindex一样，则什么都不做
        if animated && lastSelectedIndex != selectedIndex {
            let direction: LPScrollDirection = lastSelectedIndex < selectedIndex ? .right : .left
            guard let lastView = controller(at: lastSelectedIndex)?.view
                , let currView = controller(at: selectedIndex)?.view
                , let oldView = controller(at: oldSelectIndex)?.view else { return }
            let bgIndex = pageView.calcIndex(withOffset: pageView.contentOffset.x,
                                             width: pageView.frame.width)
            var bgView: UIView? = nil
            /// 这里考虑的是第一次动画还没结束，就开始第二次动画，需要把当前的处的位置的view给隐藏掉，避免出现一闪而过的情形
            if let oldAnimKeys = oldView.layer.animationKeys()
                , let lastAnimKeys = lastView.layer.animationKeys()
                , oldAnimKeys.count > 0
                , lastAnimKeys.count > 0
                , let tmpView = controller(at: bgIndex)?.view {
                if tmpView != currView && tmpView != lastView {
                    tmpView.isHidden = true
                    bgView = tmpView
                }
            }
            
            /// 这里考虑的是第一次动画还没结束，就开始第二次动画，需要把之前的动画给结束掉，oldselectindex 就是第一个动画选择的index
            pageView.layer.removeAllAnimations()
            oldView.layer.removeAllAnimations()
            lastView.layer.removeAllAnimations()
            currView.layer.removeAllAnimations()
            
            /// 这里需要还原第一次切换的view的位置
            moveBackToOriginPositionIfNeeded(oldView, index: oldSelectIndex)
            
            /// 下面就是lastview 切换到currentview的代码，direction则是切换的方向，这里把lastview和currentview 起始放到了相邻位置在动画结束的时候，还原位置
            pageView.bringSubview(toFront: lastView)
            pageView.bringSubview(toFront: currView)
            
            lastView.isHidden = false
            currView.isHidden = false
            
            let lastViewStartX = lastView.frame.origin.x
            var currViewStartX = lastViewStartX
            let offset = direction == .right ? pageView.frame.width : -pageView.frame.width
            currViewStartX += offset
            
            var lastViewAnimationX = lastViewStartX
            lastViewAnimationX -= offset
            
            let currViewAnimationX = lastViewStartX
            let lastViewEndX = lastViewStartX
            let currViewEndX = currView.frame.origin.x
            
            lastView.frame.origin.x = lastViewStartX
            currView.frame.origin.x = currViewStartX
            
            UIView.animate(withDuration: 0.3, animations: {
                lastView.frame.origin.x = lastViewAnimationX
                currView.frame.origin.x = currViewAnimationX
            }, completion: { [weak self] (finished) in
                guard let `self` = self, finished else { return }
                lastView.frame.origin.x = lastViewEndX
                currView.frame.origin.x = currViewEndX
                
                bgView?.isHidden = false
                
                self.moveBackToOriginPositionIfNeeded(currView, index: self.selectedIndex)
                self.moveBackToOriginPositionIfNeeded(lastView, index: self.lastSelectedIndex)
                self.scrollAnimation(animated)
                self.scrollEndAnimation(animated)
            })
            return
        }
        scrollAnimation(animated)
        scrollEndAnimation(animated)
    }
    
    public func index(of vc: UIViewController) -> LPIndex? {
        for cache in controllers where cache.value == vc {
            return cache.key
        }
        return nil
    }
    
    public func controller(at index: LPIndex) -> UIViewController? {
        if let ctr = controllers[index] { return ctr }
        
        if index < 0 || index >= pageCount { return nil }
        guard let ctr = dataSource?.pageController(self, viewControllerAt: index) else { return nil }
        
        controllers[index] = ctr
        addVisibleController(with: index)
        
        addCoverObservers(for: ctr, at: index)
        return ctr
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !scrollView.isDragging || scrollView != pageView { return }
        guard let delegate = delegate else { return }
        
        let offset = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let lastGuestIndex =  guessToIndex < 0 ? selectedIndex : guessToIndex
        if originOffset < offset {
            guessToIndex = LPIndex(ceil(offset / width))
        } else if originOffset >= offset {
            guessToIndex = LPIndex(floor(offset / width))
        }
        
        let maxCount = pageCount
        if isPreLoad {
            if lastGuestIndex != guessToIndex
                && guessToIndex != selectedIndex
                && guessToIndex >= 0
                && guessToIndex < maxCount {
                
                delegate.willChangeInit(in: self)
                
                if let fromVC = controller(at: selectedIndex), let toVC = controller(at: guessToIndex) {
                    delegate.pageController(self, willTransitionFrom: fromVC, to: toVC)
                    
                    toVC.beginAppearanceTransition(true, animated: true)
                    
                    if lastGuestIndex == selectedIndex {
                        fromVC.beginAppearanceTransition(false, animated: true)
                    }
                }
                
                if lastGuestIndex != selectedIndex && lastGuestIndex >= 0 && lastGuestIndex < maxCount {
                    if let lastGuestVC = controller(at: lastGuestIndex) {
                        lastGuestVC.beginAppearanceTransition(false, animated: true)
                        lastGuestVC.endAppearanceTransition()
                    }
                }
                
                addVisibleController(with: guessToIndex)
            }
        } else {
            if (guessToIndex != selectedIndex && !scrollView.isDecelerating) || scrollView.isDecelerating {
                if lastGuestIndex != guessToIndex && guessToIndex >= 0 && guessToIndex < maxCount {
                    
                    delegate.willChangeInit(in: self)
                    
                    if let currVC = controllers[selectedIndex], let guessVC = controllers[guessToIndex] {
                        delegate.pageController(self, willTransitionFrom: currVC, to: guessVC)
                        addVisibleController(with: guessToIndex)
                    }
                }
            }
        }
        
        let ratio = scrollView.contentOffset.x / scrollView.frame.width
        delegate.pageController(self, pageViewContentOffset: ratio, draging: true)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating {
            originOffset = scrollView.contentOffset.x
            guessToIndex = selectedIndex
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let ratio = targetContentOffset.pointee.x / scrollView.frame.width
        delegate?.pageController(self, pageViewContentOffset: ratio, draging: false)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let newIndex = pageView.calcIndex(withOffset: scrollView.contentOffset.x, width: scrollView.frame.width)
        let oldIndex = selectedIndex
        selectedIndex = newIndex
        
        if newIndex == oldIndex {
            if guessToIndex >= 0 && guessToIndex < pageCount {
                if let oldVC = controller(at: oldIndex), let guessVC = controller(at: guessToIndex) {
                    oldVC.beginAppearanceTransition(true, animated: true)
                    oldVC.endAppearanceTransition()
                    guessVC.beginAppearanceTransition(false, animated: true)
                    guessVC.endAppearanceTransition()
                }
            }
        } else {
            guard let newVC = controller(at: newIndex), let oldVC = controller(at: oldIndex) else { return }
            if !isPreLoad {
                newVC.beginAppearanceTransition(true, animated: true)
                oldVC.beginAppearanceTransition(false, animated: true)
            }
            newVC.endAppearanceTransition()
            oldVC.endAppearanceTransition()
        }
        
        originOffset = scrollView.contentOffset.x
        guessToIndex = selectedIndex
        
        if let lastVC = controller(at: lastSelectedIndex), let currVC = controller(at: selectedIndex) {
            delegate?.pageController(self, didTransitionFrom: lastVC, to: currVC)
        }
    }
}

// MARK: - Private Func

extension LPPageController {
    
    /// 交互切换的时候 是否预加载
    private var isPreLoad: Bool {
        return dataSource?.isPreLoad(in: self) ?? true
    }
    
    private var pageCount: Int {
        return dataSource?.numberOfControllers(in: self) ?? 0
    }
    
    private func updatePageViewLayoutIfNeed() {
        if pageView.frame.width > 0.0 {
            let width = CGFloat(pageCount) * pageView.frame.width
            pageView.updateLayout(with: CGSize(width: width, height: 1.0))
        }
    }
    
    private func updatePageViewDisplayIndexIfNeed() {
        if pageView.frame.width <= 0.0 { return }
        let offset = pageView.calcOffset(with: selectedIndex,
                                         width: pageView.frame.width,
                                         maxWidth: pageView.contentSize.width)
        if offset.x != pageView.contentOffset.x || offset.y != pageView.contentOffset.y {
            pageView.contentOffset = offset
        }
        addVisibleController(with: selectedIndex)
    }
    
    private func addVisibleController(with index: LPIndex) {
        if index < 0 || index >= pageCount { return }
        guard let ctr = controller(at: index) else { return }
        addChildVC(ctr)
        
        var originY: CGFloat = 0.0
        if let y = dataSource?.pageController(self, originYForSubViewAt: index) {
            originY = y
        }
        ctr.view.frame = pageView.calcVisibleFrame(with: index, y: originY)
    }
    
    private func addChildVC(_ childVC: UIViewController) {
        if childVC.parent != nil { return } // 如果子控制器已经存在则不再添加
        addChildViewController(childVC)
        pageView.addSubview(childVC.view)
        didMove(toParentViewController: childVC)
    }
    
    private func scrollAnimation(_ animated: Bool) {
        let offset = pageView.calcOffset(with: selectedIndex,
                                         width: pageView.frame.width,
                                         maxWidth: pageView.contentSize.width)
        pageView.setContentOffset(offset, animated: false)
    }

    private func scrollBeginAnimation(_ animated: Bool) {
        if let vc = controller(at: selectedIndex) {
            vc.beginAppearanceTransition(true, animated: animated)
        }
        if selectedIndex != lastSelectedIndex, let vc = controller(at: lastSelectedIndex) {
            vc.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    private func scrollEndAnimation(_ animated: Bool) {
        if let vc = controller(at: selectedIndex) {
            vc.endAppearanceTransition()
        }
        if selectedIndex != lastSelectedIndex, let vc = controller(at: lastSelectedIndex) {
            vc.endAppearanceTransition()
        }
        if let delegate = delegate
            , let fromVC = controller(at: lastSelectedIndex)
            , let toVC = controller(at: selectedIndex) {
            delegate.pageController(self, didLeaveFrom: fromVC, to: toVC)
        }
    }
    
    private func moveBackToOriginPositionIfNeeded(_ view: UIView?, index: LPIndex) {
        guard let destView = view, index >= 0, index < pageCount else { return }
        let originPostion = pageView.calcOffset(with: index,
                                                width: pageView.frame.width,
                                                maxWidth: pageView.contentSize.width)
        if destView.frame.origin.x != originPostion.x {
            destView.frame.origin = originPostion
        }
    }
    
    private func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer? {
        if let nav = navigationController
            , let recognizers = nav.view.gestureRecognizers
            , recognizers.count > 0 {
            for recognizer in recognizers where recognizer is UIScreenEdgePanGestureRecognizer {
                return recognizer as? UIScreenEdgePanGestureRecognizer
            }
        }
        return nil
    }
}

// MARK: - 
// MARK: - Cover

extension LPPageController {
    
    private func addCoverObservers(for controller: UIViewController, at index: LPIndex) {
        guard let dataSource = controller as? LPPageChildControllerDataSource
            , let scrollView = dataSource.scrollView(for: self) else { return }
        scrollView.scrollsToTop = false
        scrollView.tag = index
        
        if let coverDelegate = coverDelegate {
            let topInset = coverDelegate.pageController(self, topInsetForSubScrollViewAt: index)
            scrollView.contentInset.top = topInset
            
            /// iOS11 苹果加了一个安全区域 会自动修改scrollView的contentOffset
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
        }
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.initial, .new], context: nil)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.initial, .new], context: nil)
    }
    
    private func removeCoverObservers() {
        for item in controllers {
            if let dataSource = item.value as? LPPageChildControllerDataSource
                , let scrollView = dataSource.scrollView(for: self) {
                scrollView.removeObserver(self, forKeyPath: "contentOffset")
                scrollView.removeObserver(self, forKeyPath: "contentSize")
            }
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let scrollView = object as? UIScrollView, let keyPath = keyPath else { return }
        let index = scrollView.tag
        if keyPath == "contentOffset" {
            guard let coverDelegate = coverDelegate
                , let delegate = delegate
                , !delegate.cannotScrollWithPageOffset(in: self) else { return }
            
            if let lastSize = lastContentSize[index], ceil(lastSize) == ceil(scrollView.contentSize.height) {
                lastContentOffset[index] = scrollView.contentOffset.y
            }
            
            let offset = scrollView.contentOffset.y
            coverDelegate.pageController(self, verticalScrollWithPageOffset: offset, at: index)
            
        } else if keyPath == "contentSize" {
            if let lastSize = lastContentSize[index], ceil(lastSize) != ceil(scrollView.contentSize.height) {
                lastContentSize[index] = scrollView.contentSize.height
                if let lastOffset = lastContentOffset[index] {
                    scrollView.contentOffset = CGPoint(x: 0.0, y: lastOffset)
                }
            } else {
                lastContentSize[index] = scrollView.contentSize.height
            }
        }
    }
    
    private func removeFromParentVC(for controller: UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
}
