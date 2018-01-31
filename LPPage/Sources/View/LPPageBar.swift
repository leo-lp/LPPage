//
//  LPPageBar.swift
//  LPPage
//
//  Created by lipeng on 2017/11/3.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public class LPPageBar: UIScrollView {
    /// 能否移动indicator
    lazy var canMoveIndicator: Bool = false
    
    // MARK: - Private Property
    
    private lazy var items: [LPPageBarItem] = []
    private lazy var selectedIndex: LPIndex = 0
    
    private var indicator: LPIndicatorView?
        
    private weak var barDataSource: LPPageBarDataSource?
    private weak var barDelegate: LPPageBarDelegate?
    private weak var indicatorDalegate: LPIndicatorViewDataSource?
    
    // MARK: - Init Func
    
    deinit {
        #if DEBUG
            print("LPPageBar -> relese memory.")
        #endif
    }
    
    convenience init(frame: CGRect,
                     dataSource: LPPageBarDataSource?,
                     delegate: LPPageBarDelegate?,
                     indicatorDalegate: LPIndicatorViewDataSource?) {
        self.init(frame: frame)
        self.barDataSource = dataSource
        self.barDelegate = delegate
        self.indicatorDalegate = indicatorDalegate
        
        setupProperty()
        setupBarItems()
        setupIndicatorView()
        setupFirstIndex()
    }
    
    // MARK: - Public Func
    
    /// pageview滑动的接口
    public func indicatorViewScroll(toContentRatio ratio: CGFloat) {
        guard let indicator = indicator, canMoveIndicator else { return }
        
        let fromIndex = Int(ceil(ratio) - 1)
        if fromIndex < 0 || items.count <= fromIndex + 1 { return }
        
        let currItem = items[fromIndex]
        let nextItem = items[fromIndex + 1]
        let firstItem = items[0]
        let lastItem = items[items.count - 1]
        
        var moveCenterX = currItem.center.x + (ratio - CGFloat(fromIndex)) * (nextItem.center.x - currItem.center.x)
        if moveCenterX <= firstItem.center.x {
            moveCenterX = firstItem.center.x
        } else if moveCenterX >= lastItem.center.x {
            moveCenterX = lastItem.center.x
        }
        
        indicator.center.x = moveCenterX
    }
    
    public func indicatorViewScroll(to index: LPIndex) {
        guard let indicator = indicator
            , canMoveIndicator
            , index >= 0 && index < items.count else { return }
        indicator.updateFrame(in: items[index])
    }
    
    public func scrollItem(to index: LPIndex) {
        if index < 0 || index >= items.count || contentSize.width < frame.width {
            return
        }
        let nextItem = items[index]
        let itemExceptInScreen: CGFloat = UIScreen.lp_width - nextItem.frame.width
        let itemPaddingInScreen: CGFloat = itemExceptInScreen / 2.0
        
        let lastItem = items[items.count-1]
        
        let offsetX: CGFloat = max(0, min(nextItem.frame.origin.x - itemPaddingInScreen,
                                          lastItem.frame.origin.x - itemExceptInScreen))
        var nextPoint = CGPoint(x: offsetX, y: 0)
        
        /// 最后一个
        if index == items.count - 1 && index != 0 {
            nextPoint.x = contentSize.width - frame.width + contentInset.right
        }
        
        setContentOffset(nextPoint, animated: true)
    }
    
    public func reloadHighlight(to index: LPIndex) {
        selectedIndex = index
        reloadHighlight()
    }
}

// MARK: - Private Func

extension LPPageBar {

    @objc private func itemClicked(_ sender: UIControl) {
        let idx = sender.tag
        if selectedIndex == idx { return }

        barDelegate?.pageBar(self, didSelectItemAt: idx)
        selectedIndex = idx
        reloadHighlight()
        scrollItem(to: idx)
        indicatorViewScroll(to: idx, animatied: true)
    }

    private func reloadHighlight() {
        for (idx, item) in items.enumerated() {
            item.isSelected = (idx == selectedIndex)
        }
    }
    
    /// 点击 和初始化使用
    private func indicatorViewScroll(to index: LPIndex, animatied: Bool) {
        guard let indicator = indicator
            , index >= 0 && index < items.count else { return reloadHighlight() }
        if animatied {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let `self` = self else { return }
                indicator.updateFrame(in: self.items[index])
            }, completion: { [weak self] (finished) in
                self?.reloadHighlight()
            })
        } else {
            indicator.updateFrame(in: items[index])
            reloadHighlight()
        }
    }
}

// MARK: - Private Setup Func

extension LPPageBar {
    
    private func setupProperty() {
        backgroundColor = UIColor.clear
        contentSize = .zero
        isDirectionalLockEnabled = true
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        /// iOS11 苹果加了一个安全区域 会自动修改scrollView的contentOffset
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    private func setupBarItems() {
        guard let dataSource = barDataSource else { return print("dataSource不能为nil") }
        
        if items.count > 0 { items.removeAll() }
        subviews.forEach { $0.removeFromSuperview() }
        
        var totalWidth: CGFloat = 0.0
        var offset: CGFloat = 0.0
        let itemLROffset: CGFloat = dataSource.itemLeftOffset(for: self)
        let itemNum = dataSource.numberOfItems(in: self)
        for idx in 0..<itemNum {
            totalWidth += dataSource.pageBar(self, widthForItemAt: idx)
        }
        if (totalWidth + 2 * itemLROffset) > frame.width {
            offset = itemLROffset
        } else {
            offset = (frame.width - totalWidth) / 2.0
        }
        
        for idx in 0..<itemNum {
            let itemW = dataSource.pageBar(self, widthForItemAt: idx)
            let top = dataSource.pageBar(self, topForItemAt: idx)
            let item = LPPageBarItem(frame: CGRect(x: offset, y: top, width: itemW, height: frame.height))
            
            item.normalTitleColor = dataSource.pageBar(self, colorForTitleAt: idx)
            item.selectedTitleColor = dataSource.pageBar(self, colorForSelectTitleAt: idx)
            item.titleLabel.font = dataSource.pageBar(self, fontForTitleAt: idx)
            item.titleLabel.text = dataSource.pageBar(self, titleForItemAt: idx)
            item.tag = idx
            item.isUserInteractionEnabled = true
            item.addTarget(self, action: #selector(itemClicked), for: .touchUpInside)
            addSubview(item)
            
            item.titleLabel.sizeToFit()
            item.titleLabel.center = CGPoint(x: itemW / 2.0, y: frame.height / 2)
            
            items.append(item)
            offset += itemW
        }
        
        reloadHighlight()
        
        contentSize = CGSize(width: offset, height: frame.height)
        backgroundColor = UIColor.clear
    }
    
    private func setupIndicatorView() {
        guard let delegate = indicatorDalegate
            , let style = delegate.styleForIndicatorView(in: self) else { return }
        
        /// 创建LPIndicatorView
        let indicator = LPIndicatorView(style: style)
        insertSubview(indicator, at: 0)
        self.indicator = indicator
        canMoveIndicator = true
    }
    
    private func setupFirstIndex() {
        let index = barDataSource?.defaultSelectedIndex(in: self) ?? 0
        selectedIndex = index
        scrollItem(to: index)
        indicatorViewScroll(to: index, animatied: false)
    }
}
