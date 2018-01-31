//
//  LPPageChildControllerProtocol.swift
//  LPPage
//
//  Created by lipeng on 2017/11/21.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public protocol LPPageChildControllerDataSource: NSObjectProtocol {
    
    /// 如果Page带有Cover且需要PageBar或Cover能上下拖动，则ChildController需要实现此方法
    ///
    /// - Parameter pageController: ChildController的父控制器
    /// - Returns: 如果ChildController的RootView或者SubView继承自UIView请返回nil
    func scrollView(for pageController: LPPageController) -> UIScrollView?
}
