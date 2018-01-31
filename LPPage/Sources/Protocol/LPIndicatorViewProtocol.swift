//
//  LPIndicatorViewProtocol.swift
//  LPPage
//
//  Created by lipeng on 2017/11/21.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public protocol LPIndicatorViewDataSource: NSObjectProtocol {
    
    /// 设置Indicator的样式
    ///
    /// - Parameter pageBar: Indicator的父视图
    /// - Returns: 表示Indicator的样式信息；详情请见“LPIndicatorStyle”
    func styleForIndicatorView(in pageBar: LPPageBar) -> LPIndicatorStyle?
}
