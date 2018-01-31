//
//  LPPageView.swift
//  LPPage
//
//  Created by lipeng on 2017/11/3.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public class LPPageView: UIScrollView {
    
    // MARK: - Init Func
    
    deinit {
        #if DEBUG
            print("LPPageView -> relese memory.")
        #endif
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override func addSubview(_ view: UIView) {
        if view.superview == nil {
            super.addSubview(view)
        }
    }

    // MARK: - Public Func
    
    public func calcVisibleFrame(with index: LPIndex, y: CGFloat) -> CGRect {
        let x = CGFloat(index) * frame.width
        return CGRect(x: x, y: y, width: frame.width, height: frame.height - y)
    }
    
    public func calcOffset(with index: LPIndex, width: CGFloat, maxWidth: CGFloat) -> CGPoint {
        var x = CGFloat(index) * width
        if x < 0.0 {
            x = 0.0
        }
        if maxWidth > 0.0 && x > maxWidth - width {
            x = maxWidth - width
        }
        return CGPoint(x: x, y: 0.0)
    }
    
    public func calcIndex(withOffset offset: CGFloat, width: CGFloat) -> LPIndex {
        var index = Int(offset / width)
        if index < 0 {
            index = 0
        }
        return index
    }
    
    public func updateLayout(with size: CGSize) {
        if size.width != contentSize.width || size.height != contentSize.height  {
            contentSize = size
        }
    }
}

// MARK: - Private Func

extension LPPageView {
    
    private func commonInit() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        backgroundColor = UIColor.clear
        scrollsToTop = false
        
        /// iOS11 苹果加了一个安全区域 会自动修改scrollView的contentOffset
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
}
