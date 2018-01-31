//
//  LPPageBarProtocol.swift
//  LPPage
//
//  Created by lipeng on 2017/11/15.
//  Copyright © 2017年 lipeng. All rights reserved.
//

import UIKit

public protocol LPPageBarDataSource: NSObjectProtocol {
    func pageBar(_ pageBar: LPPageBar, titleForItemAt index: LPIndex) -> String?
    func itemLeftOffset(for pageBar: LPPageBar) -> CGFloat
    func numberOfItems(in pageBar: LPPageBar) -> LPIndex
    
    func pageBar(_ pageBar: LPPageBar, widthForItemAt index: LPIndex) -> CGFloat
    
    func pageBar(_ pageBar: LPPageBar, topForItemAt index: LPIndex) -> CGFloat
    func pageBar(_ pageBar: LPPageBar, colorForTitleAt index: LPIndex) -> UIColor
    func pageBar(_ pageBar: LPPageBar, colorForSelectTitleAt index: LPIndex) -> UIColor
    func pageBar(_ pageBar: LPPageBar, fontForTitleAt index: LPIndex) -> UIFont
    func defaultSelectedIndex(in pageBar: LPPageBar) -> LPIndex
}

public protocol LPPageBarDelegate: NSObjectProtocol {
    func pageBar(_ pageBar: LPPageBar, didSelectItemAt index: LPIndex) -> Void
}
