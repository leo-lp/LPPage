//
//  LPCoverControllerProtocol.swift
//  LPPage
//
//  Created by lipeng on 2017/11/20.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public protocol LPCoverControllerDelegate: NSObjectProtocol {
    /// 用于设置子controller的scrollview的inset
    func pageController(_ pageController: LPPageController, topInsetForSubScrollViewAt index: LPIndex) -> CGFloat
    
    /// 垂直滑动的回调
    func pageController(_ pageController: LPPageController, verticalScrollWithPageOffset realOffset: CGFloat, at index: LPIndex) -> Void
}
